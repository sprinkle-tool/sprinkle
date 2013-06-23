*   Default package options (see Package docs)

    *Koen Punt*
    
*   Add the file installer so we can stop doing templates with `transfer`

    *Josh Goebel*

*   Officially depreciate transfer :render and the ability to render just by passing
    a multi-line string as the transfer source.  If you want to render templates see the
    new `render()` and `template()` (rendering.rb) helpers and the `file` installer.
    
    *Josh Goebel*

*   A users own post :install hooks should happen after a file has completely been moved
    (when using sudo this was not the case)
    
    *Koen Punt*

*   Remove the Deployment module from Object.  

    If anyone is relying on the behavior of placing their deployment block in a required 
    file then they will first need to manually add the module back to the Object class
    themselves.  Polluting Object is generally bad.

    *Josh Goebel*
    
*   Add support for specifying the Net::SSH keys property

    *Chris Kimpton*

*   push_text was escaping & and / when it should not be

    *Stefano Diem Benatti*

*   Sprinkle `sudo_cmd` and Capistrino should work together instead of getting in each others way
    
    When using the capistrano actor `sudo_cmd` will now use the capistrano
    generated sudo command and therefore automatically deal with password
    prompts, etc.  This should fix hangs when installers try to call `sudo` on 
    the other side of a pipe operation and capistrano can not recognize the
    password prompt.

*   Sprinkle executable should return an error code if there was a failure

    *Michael Nigh*
    
*   verify of local actor was never returning false so installers would never be executed

    *Edgars Beigarts*

*   Capistrano actor now defaults to loading "Capfile" not "deploy" when no block is given.
    If for some reason you just have a 'deploy' file in your root folder you
    should `capify .` your setup and move your deploy.rb file into the config
    folder.  Or you can provide a block with `recipe 'deploy'` to force the
    old behavior.
    
    *Josh Goebel*
    
*   Capistrano actor now uses the configured setting of `run_method`, instead of always sudo.
    The default Capistrano setup prefers sudo, so nothing should change for 
    most users.  If you want to NOT use sudo to run commands you can set 
    `use_sudo` or `run_method` accordingly in your capistrano recipes:
    `set :use_sudo, false` or `set :run_method, :run`
    
    *Michael Nigh*
