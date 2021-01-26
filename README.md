
## CarthageProj

## 安装 `Carthage`
```sh
brew install carthage
```

## 1.当前目录下新建Cartfile文件
语法参考 https://blog.csdn.net/Deft_MKJing/article/details/106979989

## 2.执行下载脚本

```sh
carthage update --no-use-binaries --platform iOS --no-build
```

--no-build参数防止编译，后续我们需要根据自己的脚本来编译

## 3.执行编译脚本

```sh
./build-static-carthage.sh -p ios -d VOOV_QCloudCOSXML AFNetworking
```

注意这里，如果类似腾讯云这种 https://git.code.oa.com/ibg-social/VOOV_QCloudCOSXML 
老的项目中 Dependency "VOOV_QCloudCOSXML" has no shared framework schemes for any of the platforms: iOS 
需要managerd scheme 把share选上，如果是老的项目，需要重新删掉，然后再勾上  执行编译，如果依赖core这种静态库，那么需要core也支持所有架构
