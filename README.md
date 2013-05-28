Env setup
===================
1. Add as submodule in parent project:  `git submodule add git@github.com:riser/env.git` in parent project root.
2. Enter env directory: `cd env`
3. Initialize env submodules: `git submodule update --init`
4. Create file `<parent_project>/config/project.json` with something similar to the following:

        {
            "project_name": "seed-project",

            "vagrant": {
                "web": 
                    "host": "www.local",
                    "ip": "192.168.33.1",
                    "ports": {
                        "80": "8080"
                    }
                }
            }
        }
    
5. All manifests placed in `<parent_project>/config/manifests` will automatically run when provisioning, there must be at least one .pp file in that directory, even if it is an empty file.
6. Custom config file templates for project can be placed in `<parent_project>/config/templates/`
7. Put custom enviroment .json config files in `<project_parent>/config/dev/`, settings in `<project_parent>/config/dev/common.json` will override settings in `<project_parent>/config/common.json`
