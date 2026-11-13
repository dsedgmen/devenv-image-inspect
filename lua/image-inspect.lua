-- Neovim frontend for devenv-image-inspect CLI
local M = {}

local function cli_path()
  if vim.g.image_inspect_cli and vim.g.image_inspect_cli ~= "" then
    return vim.g.image_inspect_cli
  end
  local candidates = {}
  local env = vim.env.DEVENV_IMAGE_INSPECT_DIR
  if env and env ~= "" then
    table.insert(candidates, env .. "/bin/devenv-image-inspect")
  end
  local src = debug.getinfo(1, "S").source
  if src:sub(1, 1) == "@" then
    local root = vim.fn.fnamemodify(src:sub(2), ":h:h")
    table.insert(candidates, root .. "/bin/devenv-image-inspect")
  end
  table.insert(candidates, vim.fn.expand("~/.local/bin/devenv-image-inspect"))
  table.insert(candidates, "/usr/bin/devenv-image-inspect")
  for _, c in ipairs(candidates) do
    if vim.fn.executable(c) == 1 then
      return c
    end
  end
  if vim.fn.executable("devenv-image-inspect") == 1 then
    return "devenv-image-inspect"
  end
  return nil
end

local function resolve_ref(ref)
  if ref and ref ~= "" then
    return ref
  end
  local cword = vim.fn.expand("<cWORD>")
  if cword:match("^[%w._/-]+:[%w._-]+$") or cword:match("^[%w._/-]+$") then
    if not cword:match("^[./]") then
      return cword
    end
  end
  return vim.fn.input("Image ref: ")
end

local function run(args)
  local cli = cli_path()
  if not cli then
    vim.notify("image-inspect: devenv-image-inspect CLI not found", vim.log.levels.ERROR)
    return nil
  end
  local cmd = { cli }
  for _, a in ipairs(args) do
    table.insert(cmd, a)
  end
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("image-inspect: " .. table.concat(out, " "), vim.log.levels.ERROR)
    return nil
  end
  return out
end

local function open_buf(name, lines, filetype)
  vim.cmd("silent! botright new " .. vim.fn.fnameescape(name))
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  if filetype and filetype ~= "" then
    vim.bo[buf].filetype = filetype
  end
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  return buf
end

function M.meta(ref)
  ref = resolve_ref(ref)
  if not ref or ref == "" then
    return
  end
  local lines = run({ "meta", ref })
  if not lines then
    return
  end
  open_buf("image-meta://" .. ref, lines, "json")
end

function M.history(ref)
  ref = resolve_ref(ref)
  if not ref or ref == "" then
    return
  end
  local lines = run({ "history", ref })
  if not lines then
    return
  end
  open_buf("image-history://" .. ref, lines, "dockerfile")
end

function M.inspect(ref)
  ref = resolve_ref(ref)
  if not ref or ref == "" then
    return
  end
  local meta = run({ "meta", ref })
  if not meta then
    return
  end
  local lines = {
    "# ImageInspect: " .. ref,
    "# Commands: :ImageMeta  :ImageHistory  :ImageFs  :ImageExport",
    "# Keys: m=meta  h=history  f=fs  e=export  q=quit",
    "",
  }
  for _, l in ipairs(meta) do
    table.insert(lines, l)
  end
  local buf = open_buf("image-inspect://" .. ref, lines, "json")
  vim.b[buf].image_inspect_ref = ref
  vim.keymap.set("n", "m", function()
    M.meta(vim.b[buf].image_inspect_ref)
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "h", function()
    M.history(vim.b[buf].image_inspect_ref)
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "f", function()
    M.fs(vim.b[buf].image_inspect_ref, "/")
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "e", function()
    M.export(vim.b[buf].image_inspect_ref)
  end, { buffer = buf, silent = true })
end

local function parse_fs_line(line)
  local typ, path = line:match("^([dfl])\t(.+)$")
  return typ, path
end

function M.fs(ref, path)
  ref = resolve_ref(ref)
  if not ref or ref == "" then
    return
  end
  path = path or "/"
  if path == "" then
    path = "/"
  end
  local listing = run({ "fs", ref, path })
  if not listing then
    return
  end
  local lines = {
    "# ImageFs: " .. ref .. "  path=" .. path,
    "# <CR>=enter/open  - =parent  q=quit",
    "",
  }
  for _, l in ipairs(listing) do
    table.insert(lines, l)
  end
  local buf = open_buf("image-fs://" .. ref .. path, lines, "")
  vim.b[buf].image_inspect_ref = ref
  vim.b[buf].image_inspect_path = path
  vim.keymap.set("n", "<CR>", function()
    M.fs_enter()
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "-", function()
    M.fs_parent()
  end, { buffer = buf, silent = true })
end

function M.fs_enter()
  local ref = vim.b.image_inspect_ref
  if not ref then
    return
  end
  local line = vim.api.nvim_get_current_line()
  if line:match("^#") or line == "" then
    return
  end
  local typ, path = parse_fs_line(line)
  if not path then
    return
  end
  if typ == "d" or path:sub(-1) == "/" then
    local p = path:gsub("/$", "")
    if p == "" then
      p = "/"
    end
    M.fs(ref, p)
  else
    local lines = run({ "cat", ref, path })
    if not lines then
      return
    end
    open_buf("image-cat://" .. ref .. path, lines, "")
  end
end

function M.fs_parent()
  local ref = vim.b.image_inspect_ref
  local path = vim.b.image_inspect_path
  if not ref or not path or path == "/" then
    return
  end
  local parent = vim.fn.fnamemodify(path:gsub("/$", ""), ":h")
  if parent == "" then
    parent = "/"
  end
  M.fs(ref, parent)
end

function M.export(ref, outdir)
  ref = resolve_ref(ref)
  if not ref or ref == "" then
    return
  end
  local args = { "export", ref }
  if outdir and outdir ~= "" then
    table.insert(args, outdir)
  end
  local lines = run(args)
  if not lines then
    return
  end
  vim.notify("image-inspect: exported to " .. table.concat(lines, " "), vim.log.levels.INFO)
end

function M.setup(opts)
  opts = opts or {}
  local map_keys = opts.map_keys
  if map_keys == nil then
    map_keys = true
  end

  vim.api.nvim_create_user_command("ImageInspect", function(o)
    M.inspect(o.args)
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("ImageMeta", function(o)
    M.meta(o.args)
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("ImageHistory", function(o)
    M.history(o.args)
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("ImageFs", function(o)
    local parts = vim.split(o.args, "%s+", { trimempty = true })
    M.fs(parts[1], parts[2])
  end, { nargs = "*" })
  vim.api.nvim_create_user_command("ImageExport", function(o)
    local parts = vim.split(o.args, "%s+", { trimempty = true })
    M.export(parts[1], parts[2])
  end, { nargs = "*" })

  if map_keys then
    local leader = opts.leader or "<Leader>"
    vim.keymap.set("n", leader .. "ii", function()
      M.inspect()
    end, { silent = true, desc = "ImageInspect" })
    vim.keymap.set("n", leader .. "im", function()
      M.meta()
    end, { silent = true, desc = "ImageMeta" })
    vim.keymap.set("n", leader .. "ih", function()
      M.history()
    end, { silent = true, desc = "ImageHistory" })
    vim.keymap.set("n", leader .. "if", function()
      M.fs()
    end, { silent = true, desc = "ImageFs" })
    vim.keymap.set("n", leader .. "ie", function()
      M.export()
    end, { silent = true, desc = "ImageExport" })
  end
end

return M
