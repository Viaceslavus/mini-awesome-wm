## Shutdown menu widget

![2022-03-31_11:16:28](https://user-images.githubusercontent.com/72746829/161021856-44391c37-cb6f-4e73-9d7c-db4b3fd6aa22.png)

### Getting started

```
local shutdown = require("shutdown.shutdown")
```
### Customization
- ```shutdown.icon``` 
     + Shutdown menu icon path.
- ```shutdown.icon_opacity```
     + The number between 0 and 1: Shutdown menu icon opacity.
- ```shutdown.shutdown_icon```
     + Shutdown button icon image path.
- ```shutdown.restart_icon```
     + Restart button icon image path.
- ```shutdown.suspend_icon```
     + Suspend button icon image path.
- ```shutdown.logout_icon```
     + Logout button icon image path.

Usually there is no need to manually set up icon images paths, as default icons are located inside ```icons``` folder for each widget, so simply replacing them is also gonna work. 
