-- yay v13 init.lua - AUR Security Configuration

yay.opt.devel = false
yay.opt.clean_after = true
yay.opt.sort_by = "votes"
yay.opt.diff_menu = true
yay.opt.edit_menu = true

-- Skip recently modified AUR packages (72h cooldown)
yay.create_autocmd("UpgradeSelect", {
	callback = function(event)
		local exclude = {}
		local cutoff = os.time() - (3 * 24 * 60 * 60)
		for _, pkg in ipairs(event.data.upgrades) do
			if pkg.repository == "aur" and pkg.last_modified >= cutoff then
				yay.log.warn("Excluding recently modified:", pkg.name)
				table.insert(exclude, pkg.name)
			end
		end
		return { exclude = exclude, skip_menu = false }
	end,
})

-- Block suspicious PKGBUILD patterns
yay.create_autocmd("AURPreInstall", {
	callback = function(event)
		local blocked = {
			"curl.*|.*sh",
			"wget.*|.*bash",
			"eval%(",
			"rm %-rf /",
			"chmod 777",
			"base64 %-d",
		}
		for _, pattern in ipairs(blocked) do
			if event.data.pkgbuild:match(pattern) then
				yay.abort("[BLOCKED] Suspicious: " .. pattern)
			end
		end
	end,
})
