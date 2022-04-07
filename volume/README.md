## Volume Widget

![2022-03-31_11:16:28](https://user-images.githubusercontent.com/72746829/161021856-44391c37-cb6f-4e73-9d7c-db4b3fd6aa22.png)

### Getting started

Importing Lua module and initializing the volume: 
```
local volume = require("volume.volume")
volume { }
```
The second line without parameters sets the volume to 25 by default. 

### Customization
- ```volume.initial_value```  
     + A number between 0 and 100 (default is 25)
- ```volume.value``` 
     + Get access to current volume value.
- ```volume.bar_color```
     + Hex color value: Volume background bar color
- ```volume.handle_color```
     + Hex color value: Handle for adjusting volume level color
- ```volume.volume_icon_image```
     + String value: Icon widget image when volume value is bigger than 0
- ```volume.mute_icon_image```
     + String value: Icon widget image when volume value is 0
- ```volume.bar_width```
     + Number: volume bar width
- ```volume.bar_height```
     + Number: volume bar width
- ```volume.icon_opacity```
     + A number between 0 and 1 to adjust volume icon opacity in any state

Usually there is no need to manually set up ```volume.[volume|mute]_icon_image``` values, 
as default icons are located inside ```icons``` folder for each widget, so simply replacing them is also gonna work. 
