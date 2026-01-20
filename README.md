Above The Cloud Strange New Powers/
├── main/                 --这个文件夹里的文件需要使用modimport导入到modmain
│    ├──assets.lua        --文件系统，包括载入预制件、动画、图标
│    └──xx.lua
├── postinit/             --这个文件夹里的文件需要使用modimport导入到modmain
│    ├── components/      --修改原版组件
│    │    ├── xx.lua
│    │    └── xx.lua
│    └── prefabs/         --修改原版预制件
│         ├── xx.lua
│         └── xx.lua
├── scripts/
│    ├── components/      --存放组件，不需要任何载入
│    │    ├── xx.lua
│    │    └── xx.lua
│    └── prefabs/         --存放预制件，在assets.lua里载入
│         ├── xx.lua
│         └── xx.lua
├── modinfo.lua
└── modmain.lua