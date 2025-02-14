import SpriteKit
import GBKit

/// the scene that render the framebuffer
class GameScene: SKScene {
    private var gVM:GameBoyViewModel = GameBoyViewModel()
    
    var effectNode : SKEffectNode = SKEffectNode()
    
    /// frame buffer will be drawn in the texture of sprite
    private var screen = SKSpriteNode(color: .red, size: CGSize(width: GBConstants.ScreenWidth, height: GBConstants.ScreenHeight))
    
    /// fps counter is a text
    private var fpsLabel = SKLabelNode(text: "Hello")
    
    private var previousTime:Double = Date().timeIntervalSince1970
    
    /// if true FPS is displayed
    public var isFPSDisplayEnabled:Bool {
        get {
            return !self.fpsLabel.isHidden
        }
        set {
            self.fpsLabel.isHidden = !newValue
        }
    }
    
    public func withGVM(gVM: GameBoyViewModel) -> GameScene {
        self.gVM = gVM
        return self
    }
    
    override func didMove(to view: SKView) {
        //called once, when scene is presented
        self.initNodes()
    }
    
    /// called every frame, for framerate see SpriteView initialization
    override func update(_ currentTime: TimeInterval) {
        // update screen with framebuffer
        self.screen.texture = SKTexture(data: self.gVM.gb.motherboard.ppu.frameBuffer,
                                        size: CGSize(width: GBConstants.ScreenWidth,
                                                     height: GBConstants.ScreenHeight))
        //to avoid pixel tearing
        self.screen.texture!.filteringMode = .nearest
        
        self.updateFPSCount()
    }
    
    /// init nodes in scene
    private func initNodes() {
        //screen
        self.screen.texture = SKTexture(data: self.gVM.gb.motherboard.ppu.frameBuffer,
                                        size: CGSize(width: GBConstants.ScreenWidth,
                                                     height: GBConstants.ScreenHeight))
        self.screen.anchorPoint = CGPoint(x: 0, y: 0)
        
        //filp vertically as framebuffer contains data from top to bottom, but swift draws from bottom to top
        self.screen.yScale = -1
        self.screen.position = CGPoint(x:0, y:GBConstants.ScreenHeight) //as yScale flips, y must be offset by ScreenHeight
        
        self.addChild(self.screen)
        
        //fps label
        self.fpsLabel.fontName = "Courier"
        self.fpsLabel.fontSize = 8
        self.fpsLabel.fontColor = .white
        
        self.fpsLabel.text = "FPS: 88.88"//fake representative text to get accurate evaluation when positionning
        self.fpsLabel.position = CGPoint(x: Int(self.fpsLabel.frame.width) / 2,
                                         y: GBConstants.ScreenHeight - Int(self.fpsLabel.frame.height))
        self.addChild(self.fpsLabel)
    }
    
    /// update FPS count
    private func updateFPSCount() {
        //avoid computation if label is hidden
        if(self.isFPSDisplayEnabled){
            //manually compute FPS (accurate way)
            let currentTime = Date().timeIntervalSince1970
            let ellapsedTime = currentTime - self.previousTime
            self.previousTime = currentTime
            self.fpsLabel.text = String(format: "FPS: %.2f", 1/ellapsedTime)
        }
    }
}
