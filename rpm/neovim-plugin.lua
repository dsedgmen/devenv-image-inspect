-- Packpath loader for devenv-image-inspect-neovim RPM.
-- Does not replace ~/.config/nvim/init.lua.
local ok, mod = pcall(require, "image-inspect")
if not ok then
  local conf = "/usr/share/devenv-image-inspect/lua/image-inspect.lua"
  local ok2, mod2 = pcall(dofile, conf)
  if not ok2 then
    vim.notify(
      "devenv-image-inspect: failed to load image-inspect: " .. tostring(mod2 or mod),
      vim.log.levels.ERROR
    )
    return
  end
  mod = mod2
end
if type(mod) == "table" and type(mod.setup) == "function" then
  mod.setup()
end
