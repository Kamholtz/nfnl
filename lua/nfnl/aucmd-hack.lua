-- [nfnl] Compiled from fnl\nfnl\aucmd-hack.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local str = autoload("nfnl.string")
local function create_buf_write_post_autocmd(root_dir, ev, cfg, callback_fn, create_recursively_3f)
  local function _2_(ev_inner)
    if create_recursively_3f then
      create_buf_write_post_autocmd(root_dir, ev, cfg, callback_fn, create_recursively_3f)
    else
    end
    return callback_fn(root_dir, cfg)(ev_inner)
  end
  return vim.api.nvim_create_autocmd({"BufWritePost"}, {group = vim.api.nvim_create_augroup(str.join({"nfnl-on-write", root_dir, ev.buf}), {}), buffer = ev.buf, callback = _2_})
end
return {["create-buf-write-post-autocmd"] = create_buf_write_post_autocmd}
