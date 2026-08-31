-- ModuleScript: WorkshopAssetSpec
--
-- Spezifikation der Asset-Pipeline: was für JEDES Workshop-Asset gelten soll, und die
-- Regeln, die es prüfen.
--
-- Abgrenzung zu den *Specification-Dateien: die beschreiben EIN Asset (Maße, Palette,
-- Budgets) und sind reine Daten -- vergleichbar mit CityAlertConfig auf der Spielseite.
-- Dieses Modul hier formuliert Aussagen ÜBER diese Daten und über die daraus gebauten
-- Modelle.
--
-- WICHTIG: importiert NICHTS. Alles kommt über den ctx (siehe SpecRunner im Hauptrepo).
-- Nur so läuft dieselbe Datei in Studio und im kopflosen Prüfer.

-- Die zu prüfenden Asset-Spezifikationen, so wie sie der Runner im ctx bereitstellt.
local function assetsOf(ctx)
	local workshop = ctx.config.WorkshopAssets
	if type(workshop) ~= "table" then
		return {}
	end
	local list = {}
	for name, spec in pairs(workshop) do
		if type(spec) == "table" then
			table.insert(list, { name = name, data = spec })
		end
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

return {
	System = "WorkshopAsset",

	Rules = {
		{
			id = "workshop.spec.identity-complete",
			intent = "Jedes Asset ist eindeutig benennbar. Ohne AssetId lässt sich kein "
				.. "Modell einer Spezifikation zuordnen, und die Pipeline verliert ihren "
				.. "Bezugspunkt.",
			check = function(ctx)
				local violations = {}
				for _, asset in ipairs(assetsOf(ctx)) do
					for _, field in ipairs({ "SchemaVersion", "AssetName", "AssetId", "AssetClass" }) do
						if asset.data[field] == nil then
							table.insert(violations, asset.name .. ": " .. field .. " fehlt")
						end
					end
				end
				return violations
			end,
		},

		{
			id = "workshop.spec.budget-declared",
			intent = "Ein Asset ohne erklärtes Leistungsbudget lässt sich nicht abnehmen -- "
				.. "dann entscheidet der Zufall, wie teuer es wird. Budget heisst: eine "
				.. "positive Obergrenze für sichtbare Teile und für Gameplay-Hitboxen.",
			check = function(ctx)
				local violations = {}
				for _, asset in ipairs(assetsOf(ctx)) do
					local budget = asset.data.PerformanceBudget
					if type(budget) ~= "table" then
						table.insert(violations, asset.name .. ": PerformanceBudget fehlt")
					else
						for _, field in ipairs({ "MaxVisibleParts", "MaxGameplayHitboxes" }) do
							local value = budget[field]
							if type(value) ~= "number" or value <= 0 then
								table.insert(
									violations,
									asset.name .. ": PerformanceBudget." .. field .. " fehlt oder ist nicht positiv"
								)
							end
						end
					end
				end
				return violations
			end,
		},

		{
			id = "workshop.spec.no-permanent-effects",
			intent = "Dauerhafte Lichter und Partikel sind pro Asset verboten: bei mehreren "
				.. "gleichzeitig sichtbaren Einheiten summieren sie sich zu Bildratenverlust, "
				.. "den man im Einzeltest nie bemerkt. Effekte gehören an Ereignisse "
				.. "(Treffer, Feuern), nicht an das Modell im Ruhezustand.",
			check = function(ctx)
				local violations = {}
				for _, asset in ipairs(assetsOf(ctx)) do
					local budget = asset.data.PerformanceBudget
					if type(budget) == "table" then
						for _, field in ipairs({ "PermanentLights", "PermanentParticleEmitters", "PerPartScripts" }) do
							local value = budget[field]
							if value ~= nil and value ~= 0 then
								table.insert(
									violations,
									asset.name .. ": PerformanceBudget." .. field .. " ist " .. tostring(value) .. ", erwartet 0"
								)
							end
						end
					end
				end
				return violations
			end,
		},

		{
			id = "workshop.spec.gates-match-phase",
			intent = "Die Phasenangabe und die Quality Gates müssen zusammenpassen. Ein Asset, "
				.. "das sich als fertig ausgibt (Phase 7), aber offene Gates hat, führt die "
				.. "Pipeline vor -- dann ist die Phasenzahl nur noch Dekoration.",
			-- Marshal steht auf Phase 6 mit zwei Gates -- das ist konsistent und schlägt
			-- nicht an. Nur ab Phase 7 werden alle drei Gates verlangt.
			check = function(ctx)
				local violations = {}
				for _, asset in ipairs(assetsOf(ctx)) do
					local phase = asset.data.PipelinePhase or 0
					if phase >= 7 then
						for _, gate in ipairs({ "QualityGateA", "QualityGateB", "QualityGateC" }) do
							if asset.data[gate] ~= "Approved" then
								table.insert(
									violations,
									asset.name
										.. ": PipelinePhase="
										.. phase
										.. ", aber "
										.. gate
										.. " ist "
										.. tostring(asset.data[gate] or "nicht gesetzt")
								)
							end
						end
					end
				end
				return violations
			end,
		},

		{
			id = "workshop.build.within-budget",
			intent = "Das GEBAUTE Modell muss sein erklärtes Budget einhalten. Die Spezifikation "
				.. "allein sagt nichts -- erst der Abgleich mit der tatsächlichen Teilezahl "
				.. "macht aus dem Budget eine Zusage. Die GoldenMaster schreiben Ist und Soll "
				.. "beim Bauen als Attribute ans Modell.",
			needsRuntime = true,
			check = function(ctx)
				local violations = {}
				for _, model in ipairs(ctx.runtime.GetWorkshopModels()) do
					local visible = model.VisiblePartCount
					local visibleBudget = model.VisiblePartBudget
					local hitboxes = model.GameplayHitboxCount
					local hitboxBudget = model.GameplayHitboxBudget

					if visible and visibleBudget and visible > visibleBudget then
						table.insert(
							violations,
							model.Name .. ": " .. visible .. " sichtbare Teile, Budget " .. visibleBudget
						)
					end
					if hitboxes and hitboxBudget and hitboxes > hitboxBudget then
						table.insert(
							violations,
							model.Name .. ": " .. hitboxes .. " Gameplay-Hitboxen, Budget " .. hitboxBudget
						)
					end
					if visible and not visibleBudget then
						table.insert(
							violations,
							model.Name .. ": zählt Teile, aber trägt kein VisiblePartBudget -- Budget nicht nachprüfbar"
						)
					end
				end
				return violations
			end,
		},

		{
			id = "workshop.asset.silhouette-reads-at-distance",
			intent = "WEICH: die Silhouette muss auf Entfernung lesbar sein und darf nicht als "
				.. "Quaderstapel wirken (GeometryRules.AvoidOrthogonalBoxSilhouette). Das "
				.. "entscheidet sich am Bildschirm, nicht an einer Zahl -- prüfbar nur im "
				.. "Ansehen, bewusst ohne check.",
		},

		{
			id = "workshop.asset.belongs-to-a-city-tier",
			intent = "WEICH: jedes Asset gehört zu einer Stadtstufe (Tier/City in der "
				.. "Spezifikation) und muss sich in deren Schwierigkeitskurve einfügen. Der "
				.. "Warden-I steht auf Tier 1 (Village), der Marshal-II auf Tier 2 (Small "
				.. "Town) -- ihre Werte sollten diesem Abstand entsprechen. Ob das stimmt, "
				.. "zeigt erst das Spielgefühl.",
		},
	},
}
