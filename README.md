# SCTiledImage
Tiled Image view for iOS: display images with multiple layers of zoom / tiles

##Requirements
- iOS 8.0+
- Xcode 8.1+
- Swift 3.0+

##Introduction
Imagine, I have a very big size image and want to display it on screen then the user can zoom in/out to view the image. Of course, It takes a lot of room in memory. And in case you load the image from internet, the user have to wait for a term to view or interact with the image. So that if the user just want to view the image as minimun zoom level and don't want to zoom in/out, they will waste a lot of room in the memory (and time for image downloading as well).

Ideally, things will be better if you have images corresponded with zoom levels (an integer value) of the orginal image. You display smallest size image on the screen and if the user zoom in to the next zoom level, you just need to load the corresponded image. That is why Siclo created SCTiledImage.

##Usage
###Step 1: Resource preparing
In this example, I have an big size image (9112 x 4677) and 4 zoom level (from 0 to 3). The image size for each zoom level as below:
- zoom level 3: 1139 x 584 (device original image size for 8)
- zoom level 2: 2278 x 1169 (device original image size for 4)
- zoom level 1: 4386 x 2338 (device original image size for 2)
- zoom level 0: 9112 x 4677 (the original image size)

For now, I split up each image to smaller images with a constant size (256 x 256) and name them with `level-colum-row` format. The number of zoom level and constant size (256 x 256) depend on you.

###Step 2: Code setup
```swift
class ViewController: UIViewController {
    @IBOutlet var tiledImageScrollView: SCTiledImageScrollView!
    private var dataSource: ExampleTiledImageDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTiledImageScrollView()
    }
    
    private func setupTiledImageScrollView() {
        let imageSize = CGSize(width: 9112, height: 4677)
        let tileSize = CGSize(width: 256, height: 256)
        let zoomLevels = 4
        dataSource = ExampleTiledImageDataSource(imageSize: imageSize, tileSize: tileSize, zoomLevels: zoomLevels)
        tiledImageScrollView.set(dataSource: dataSource!)
    }
}
```

##Installation
SCTiledImage is available through CocoaPods, to install it simply add the following line to your Podfile:
```ruby
   pod "SCTiledImage"
```
