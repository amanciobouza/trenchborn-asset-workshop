local HttpService = game:GetService("HttpService")

local Report = {}

local function subjectPath(subject)
	if not subject then
		return nil
	end
	local ok, path = pcall(function()
		return subject:GetFullName()
	end)
	return ok and path or subject.Name
end

function Report.ToSerializable(result)
	local findings = {}
	for _, finding in ipairs(result.Findings) do
		table.insert(findings, {
			id = finding.Id,
			severity = finding.Severity,
			message = finding.Message,
			subject = subjectPath(finding.Subject),
		})
	end

	return {
		schemaVersion = 1,
		profileId = result.ProfileId,
		assetId = result.AssetId,
		modelName = result.ModelName,
		status = result.Status,
		blockers = result.BlockerCount,
		warnings = result.WarningCount,
		metrics = result.Metrics,
		findings = findings,
		visualReviewCriteria = result.VisualReviewCriteria,
	}
end

function Report.ToJSON(result)
	return HttpService:JSONEncode(Report.ToSerializable(result))
end

function Report.ToText(result)
	local lines = {
		string.format("[%s] %s", result.Status, result.ModelName),
		string.format("Profile: %s | Blockers: %d | Warnings: %d", result.ProfileId, result.BlockerCount, result.WarningCount),
	}
	for _, finding in ipairs(result.Findings) do
		table.insert(lines, string.format("- %s %s: %s", finding.Severity, finding.Id, finding.Message))
	end
	if #result.Findings == 0 then
		table.insert(lines, "- No deterministic findings.")
	end
	table.insert(lines, string.format("- %d visual criteria still require image review.", #result.VisualReviewCriteria))
	return table.concat(lines, "\n")
end

return Report
