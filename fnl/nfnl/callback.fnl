(local {: autoload} (require :nfnl.module))
(local core (autoload :nfnl.core))
(local str (autoload :nfnl.string))
(local fs (autoload :nfnl.fs))
(local nvim (autoload :nfnl.nvim))
(local compile (autoload :nfnl.compile))
(local config (autoload :nfnl.config))
(local api (autoload :nfnl.api))
(local notify (autoload :nfnl.notify))
(local aucmd-hack (autoload :nfnl.aucmd-hack))

(fn fennel-buf-write-post-callback-fn [root-dir cfg]
  "Builds a function to be called on buf write. Adheres to the config passed
  into this outer function."

  (fn [ev]
    "Called when we write a Fennel file located under a directory containing a
    .nfnl.fnl file. It compiles the Fennel to Lua and writes it into another
    file according to the .nfnl.fnl file configuration."

    (compile.into-file
      {: root-dir
       : cfg
       :path (fs.full-path (. ev :file))
       :source (nvim.get-buf-content-as-string (. ev :buf))})))
(fn supported-path? [file-path]
  "Returns true if we can work with the given path. Right now we support a path if it's a string and it doesn't start with a protocol segment like fugitive://..."
  (or
    (when (core.string? file-path)
      (not (file-path:find "^[%w-]+:/")))
    false))

(fn fennel-filetype-callback [ev]
  "Called whenever we enter a Fennel file. It walks up the tree to find a
  .nfnl.fnl (which can contain configuration). If found, we initialise the
  compiler autocmd for the directory containing the .nfnl.fnl file.

  This allows us to edit multiple projects in different directories with
  different .nfnl.fnl configuration, wonderful!"

  (let [file-path (fs.full-path (. ev :file))]
    (when (supported-path? file-path)
      (let [file-dir (fs.basename file-path)
            {: config : root-dir : cfg} (config.find-and-load file-dir)]

        (when config
          (when (cfg [:verbose])
            (notify.info "Found nfnl config, setting up autocmds: " root-dir))

          (aucmd-hack.create-buf-write-post-autocmd root-dir 
                                                    ev 
                                                    cfg  
                                                    fennel-buf-write-post-callback-fn 
                                                    (= (vim.fn.has "windows") 1))

          (vim.api.nvim_buf_create_user_command
            ev.buf :NfnlFile
            #(api.dofile (core.first (core.get $ :fargs)))
            {:desc "Run the matching Lua file for this Fennel file from disk. Does not recompile the Lua, you must use nfnl to compile your Fennel to Lua first. Calls nfnl.api/dofile under the hood."
             :force true
             :complete "file"
             :nargs "?"})

          (vim.api.nvim_buf_create_user_command
            ev.buf :NfnlCompileAllFiles
            #(api.compile-all-files (core.first (core.get $ :fargs)))
            {:desc "Executes (nfnl.api/compile-all-files) which will, you guessed it, compile all of your files."
             :force true
             :complete "file"
             :nargs "?"}))))))

{: fennel-filetype-callback
 : supported-path?}
