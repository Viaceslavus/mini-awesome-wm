## Battery Widget

![2022-03-31_11:16:28](https://user-images.githubusercontent.com/72746829/161021856-44391c37-cb6f-4e73-9d7c-db4b3fd6aa22.png)

### Getting started

Importing Lua module and initializing the battery widget: 
```
local battery = require("battery.battery")
battery { }
```
The second line without parameters initializes battery percentage. 

### Customization
- ```battery.percentage``` 
     + Get access to current battery percentage.
- ```battery.charging_icon````
     + Path to image: Icon widget image when battery is charging
- ```battery.not_charging_icon```
     + Path to image: Icon widget image when battery is not charging
- ```battery.update_timeout```
     + Number: Battery percentage update timeout
- ```battery.icon_opacity```
     + A number between 0 and 1: Icon widget image opacity in any state

Usually there is no need to set ```battery.[volume|mute]_icon_image``` values, 
as default icons are located inside ```icons``` folder for each widget, so simply replacing them is also gonna work. 
