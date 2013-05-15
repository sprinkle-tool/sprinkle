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
