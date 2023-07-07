-- [nfnl] Compiled from fnl/nfnl/config.fnl by https://github.com/Olical/nfnl, do not edit.
local autoload = require("nfnl.autoload")
local core = autoload("nfnl.core")
local fs = autoload("nfnl.fs")
local str = autoload("nfnl.string")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
local config_file_name = ".nfnl.fnl"
local function default()
  return {["compiler-options"] = {}, ["fennel-path"] = str.join(";", {"./?.fnl", "./?/init.fnl", "./fnl/?.fnl", "./fnl/?/init.fnl"}), ["fennel-macro-path"] = str.join(";", {"./?.fnl", "./?/init-macros.fnl", "./?/init.fnl", "./fnl/?.fnl", "./fnl/?/init-macros.fnl", "./fnl/?/init.fnl"}), ["source-file-patterns"] = {fs["join-path"]({"fnl", "**", "*.fnl"})}}
end
local function cfg_fn(t)
  local function _1_(path)
    return core["get-in"](t, path, core["get-in"](default(), path))
  end
  return _1_
end
local function config_file_path_3f(path)
  return (config_file_name == fs.filename(path))
end
local function find_and_load(dir)
  local found = fs.findfile(config_file_name, (dir .. ";"))
  if found then
    local config_file_path = fs["full-path"](found)
    local root_dir = fs.basename(config_file_path)
    local config_source = vim.secure.read(config_file_path)
    local ok, config = nil, nil
    if core["nil?"](config_source) then
      ok, config = false, (config_file_path .. " is not trusted, refusing to compile.")
    elseif (str["blank?"](config_source) or ("{}" == str.trim(config_source))) then
      ok, config = true, {}
    else
      ok, config = pcall(fennel.eval, config_source, {filename = config_file_path})
    end
    if ok then
      return {config = config, ["root-dir"] = root_dir, cfg = cfg_fn(config)}
    else
      notify.error(config)
      return {}
    end
  else
    return nil
  end
end
return {["find-and-load"] = find_and_load, ["config-file-path?"] = config_file_path_3f, default = default}