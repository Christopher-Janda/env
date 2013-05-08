Env setup
===================
1. Clone as subfolder in parent project:  `<project>/env`
2. Create file `<project>/config/project.json` with something similar to the following:

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
    
3. All manifests placed in `<project>/manifests` will automatically run when deployed
4. Custom config file templates for project can be placed in `<project>/templates`
