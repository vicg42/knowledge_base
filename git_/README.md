# Using specify ssh key (PC Linux)
* git clone https://github.com/vicg42/knowledge_base.git
* cd knowledge_base
* mc -e ./.git/config
    ```
        [core]
            repositoryformatversion = 0
            filemode = true
            bare = false
            logallrefupdates = true
            sshCommand="ssh -i /home/v.halavachenka/work/vicg42-github/_ssh_key/github_ssh_id_rsa"
        [remote "origin"]
            #url = https://github.com/vicg42/knowledge_base.git
            url = git@github.com:vicg42/knowledge_base.git
            fetch = +refs/heads/*:refs/remotes/origin/*
        [branch "master"]
            remote = origin
            merge = refs/heads/master
    ```

# Github (private<->public)
