(local {: autoload} (require :nfnl.module))
(local str (autoload :nfnl.string))

(fn create-buf-write-post-autocmd [root-dir ev cfg callback-fn create-recursively?]
 (vim.api.nvim_create_autocmd
   ["BufWritePost"]
   {:group (vim.api.nvim_create_augroup (str.join ["nfnl-on-write" root-dir ev.buf]) {})
    :buffer ev.buf
    :callback (fn [ev-inner] 
                ; create again
                (when create-recursively? 
                  (create-buf-write-post-autocmd root-dir 
                                                 ev 
                                                 cfg 
                                                 callback-fn 
                                                 create-recursively?))
                ((callback-fn root-dir cfg) ev-inner))}))

{: create-buf-write-post-autocmd}
