

import SpriteKit
import UIKit


struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Edge: UInt32 = 0b1
    static let Character: UInt32 = 0b10
    static let Collider: UInt32 = 0b100
    static let Obstacle: UInt32 = 0b1000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var sceneCreated = false
    var gameStarted = false
    var canJump = false
    var shouldSpawnObstacle = false
    var shouldUpdateScore = false
    let dinoDarkColor = SKColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
    let titleNode = SKLabelNode(fontNamed: "Courier")
    let subtitleNode = SKLabelNode(fontNamed: "Courier")
    let scoreNode = SKLabelNode(fontNamed: "Courier")
    let topSky = SKSpriteNode()
    var groundNode = SKShapeNode()
    var currentScore = 0
    let iron1 = SKTexture(imageNamed: "run1")
    let iron2 = SKTexture(imageNamed: "run2")
    let iron3 = SKTexture(imageNamed: "run3")
    let iron4 = SKTexture(imageNamed: "run4")
    var dinoSpriteNode = SKSpriteNode(imageNamed: "run1")

    
    override func didMove(to view: SKView) {
        if !sceneCreated {
            sceneCreated = true
            createSceneContents()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        jump()
    }
    
    func startGame() {
        srand48(Int(arc4random()))
        
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                self.removeChildren(in: [node])
            }
        }
        
        gameStarted = true
        canJump = true
        currentScore = 0
        shouldUpdateScore = true
        updateScore()
        titleNode.isHidden = true
        subtitleNode.isHidden = true
        self.shouldSpawnObstacle = true
        self.spawnObstacle()
        self.spawnCloud()
        dinoSpriteNode.isPaused = false
        
    }
    
    func createSceneContents() {
        self.topSky.color = UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1)
        self.topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.topSky.position = CGPoint(x: frame.midX, y: frame.height)
        self.topSky.zPosition = -40
        self.topSky.size = CGSize(width: self.frame.width, height: self.frame.height * 0.67)
        
        let yPos : CGFloat = size.height * 0.33
        let startPoint = CGPoint(x: 0, y: yPos)
        let endPoint = CGPoint(x: size.width, y: yPos)
        
        let groundSize = CGSize(width: size.width, height: size.height * 0.33)
        self.groundNode = SKShapeNode(rect: CGRect(origin: CGPoint(), size: groundSize))
        self.groundNode.fillColor = SKColor(red:0.99, green:0.92, blue:0.55, alpha:1.0)
        self.groundNode.strokeColor = SKColor.clear
        self.groundNode.zPosition = 1
        
        self.groundNode.physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        if let Gn = self.groundNode.physicsBody {
            Gn.categoryBitMask = PhysicsCategory.Edge | PhysicsCategory.Collider
            Gn.contactTestBitMask = PhysicsCategory.Character
            Gn.friction = 0
            Gn.restitution = 0
            Gn.linearDamping = 0
            Gn.angularDamping = 1
            Gn.isDynamic = false
            Gn.affectedByGravity = false
            Gn.allowsRotation = false
        }
        


        self.addChild(topSky)
        self.addChild(titleLabel())
        self.addChild(subtitleLabel())
        self.addChild(dinoSprite())
        self.addChild(scoreLabel())
        self.addChild(groundNode)
        self.physicsWorld.contactDelegate = self
        //self.backgroundColor = SKColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        self.scaleMode = .aspectFit
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        //self.logger()
        self.spawnObstacle()
        self.spawnCloud()
    }
    
    func titleLabel() -> SKLabelNode {
        titleNode.text = "PikaRun"
        titleNode.fontSize = 10
        titleNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-10)
        titleNode.fontColor = dinoDarkColor
        titleNode.zPosition = 50
        
        return titleNode
    }
    
    func subtitleLabel() -> SKLabelNode {
        subtitleNode.text = "Touch anywhere to begin..."
        subtitleNode.fontSize = 7
        subtitleNode.position = CGPoint(x: self.frame.midX, y: self.frame.maxY-20)
        subtitleNode.fontColor = dinoDarkColor
        subtitleNode.zPosition = 50
        
        return subtitleNode
    }
    
    func scoreLabel() -> SKLabelNode {
        scoreNode.text = generateScore()
        scoreNode.fontSize = 15
        scoreNode.horizontalAlignmentMode = .right
        scoreNode.position = CGPoint(x: self.frame.maxX - 4, y:self.frame.maxY - 15)
        scoreNode.fontColor = dinoDarkColor
        scoreNode.zPosition = 80
        
        return scoreNode
    }
    
    func generateScore() -> String {
        return String(format: "%07d", currentScore)
    }
    
    func dinoSprite() -> SKSpriteNode {
        dinoSpriteNode.position = CGPoint(x: 100, y: self.frame.height * 0.31 + dinoSpriteNode.size.height/2)
        dinoSpriteNode.setScale(0.12)

//        dinoSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: max(dinoSpriteNode.size.width / 2,
//                                                                       dinoSpriteNode.size.height / 2))
        dinoSpriteNode.physicsBody = SKPhysicsBody(texture: iron1, size: dinoSpriteNode.size)
        if let pb = dinoSpriteNode.physicsBody {
            pb.isDynamic = true
            pb.affectedByGravity = true
            pb.allowsRotation = false
            pb.categoryBitMask = PhysicsCategory.Character
            pb.collisionBitMask = PhysicsCategory.Edge
            pb.contactTestBitMask = PhysicsCategory.Collider
            pb.restitution = 0
            pb.friction = 1
            pb.linearDamping = 1
            pb.angularDamping = 1
        }
        let animateLights = SKAction.sequence([
            SKAction.wait(forDuration: 0.2, withRange: 0.5),
            SKAction.animate(with: [self.iron1, self.iron2,self.iron3,self.iron4], timePerFrame: 0.2)
            ])
        let changeLight = SKAction.repeatForever(animateLights)
        

        dinoSpriteNode.run(changeLight)
        return dinoSpriteNode
    }
   
    
    func endGame() {
        
        titleNode.isHidden = false
        subtitleNode.isHidden = false
        dinoSpriteNode.isPaused = true
        canJump = false
        shouldSpawnObstacle = false
        gameStarted = false
        shouldUpdateScore = false
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                node.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }
    
    func jump() {
        
        if !gameStarted {
            print("game Stared")
            startGame()
        }
        
        if !canJump {
            print("cant jump!")
            
            return
        }
        
        if let pb = dinoSpriteNode.physicsBody {
            pb.applyImpulse(CGVector(dx:0, dy:10), at: dinoSpriteNode.position)
        }
    }
    
    func spawnCloud() {
        if self.shouldSpawnObstacle == false {
            return
        }
        
        let x = arc4random() % 3;
        if x != 2 {
            
            if x == 0 {
                let oi = SKSpriteNode(imageNamed: "cloud1")
                let scale = CGFloat(drand48() * 1 + 0.6)
                let rand_int = CGFloat(arc4random_uniform(20) + 20)
                oi.setScale(scale)
                oi.position = CGPoint(x: self.frame.maxX-20, y: self.frame.maxY - rand_int)
                oi.zPosition = -30
                oi.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "cloud1"), size: oi.size)
                if let pb = oi.physicsBody {
                    pb.isDynamic = true
                    pb.affectedByGravity = false
                    pb.allowsRotation = false
                    pb.categoryBitMask = PhysicsCategory.Obstacle
                    pb.contactTestBitMask = PhysicsCategory.Character
                    pb.collisionBitMask = 0
                    pb.restitution = 0
                    pb.friction = 0
                    pb.linearDamping = 0
                    pb.angularDamping = 0
                    pb.velocity = CGVector(dx: -180, dy: 0)
                }
                self.addChild(oi)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
                    if self.shouldSpawnObstacle {
                        self.removeChildren(in: [oi])
                    }
                })
                
            }
            else {
                let oi = SKSpriteNode(imageNamed: "cloud2")
                let scale = CGFloat(drand48() * 1 + 0.6)
                let rand_int = CGFloat(arc4random_uniform(15) + 20)
                oi.setScale(scale)
                oi.position = CGPoint(x: self.frame.maxX-20, y: self.frame.maxY - rand_int)
                oi.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "cloud2"), size: oi.size)
                if let pb = oi.physicsBody {
                    pb.isDynamic = true
                    pb.affectedByGravity = false
                    pb.allowsRotation = false
                    pb.categoryBitMask = PhysicsCategory.Obstacle
                    pb.contactTestBitMask = PhysicsCategory.Character
                    pb.collisionBitMask = 0
                    pb.restitution = 0
                    pb.friction = 0
                    pb.linearDamping = 0
                    pb.angularDamping = 0
                    pb.velocity = CGVector(dx: -200, dy: 0)
                    
                }
                self.addChild(oi)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
                    if self.shouldSpawnObstacle {
                        self.removeChildren(in: [oi])
                    }
                })
                
                
                
            }
            
        }
        
        
        let randDelay = drand48() * 1.3 - Double(currentScore) / 1000.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 + randDelay, execute: {
            if self.shouldSpawnObstacle == true {
                self.spawnCloud()
            }
        })
    }
    
    func spawnObstacle() {
        if self.shouldSpawnObstacle == false {
            return
        }
        
        let x = arc4random() % 3;
        
        if x != 2 {
            let ob = SKSpriteNode(imageNamed: "Obstacle2")
            let scale = CGFloat(drand48() * 0.3 + 0.37)
            ob.setScale(scale)
            ob.position = CGPoint(x: self.frame.maxX-10, y: ob.size.height/2 + self.frame.height * 0.33)
//            ob.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "Obstacle2"), size: ob.size)
            ob.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ob.size.width,
                                                               height: ob.size.height))

            if let pb = ob.physicsBody {
                pb.isDynamic = true
                pb.affectedByGravity = false
                pb.allowsRotation = false
                pb.categoryBitMask = PhysicsCategory.Obstacle
                pb.contactTestBitMask = PhysicsCategory.Character
                pb.collisionBitMask = 0
                pb.restitution = 0
                pb.friction = 0
                pb.linearDamping = 0
                pb.angularDamping = 0
                pb.velocity = CGVector(dx: -200, dy: 0)
            }

            if (currentScore % 13 == 0){
                print(currentScore % 13)
                ob.physicsBody?.velocity.dx -= 10
            }
            
            self.addChild(ob)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
                if self.shouldSpawnObstacle {
                    self.removeChildren(in: [ob])
                }
            })
        }
        
        let randDelay = drand48() * 0.1 - Double(currentScore) / 1000.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9 + randDelay, execute: {
            if self.shouldSpawnObstacle == true {
                self.spawnObstacle()
            }
        })
    }
    
    func updateScore() {
        currentScore += 1
        scoreNode.text = generateScore()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if (self.shouldUpdateScore) {
                self.updateScore()
            }
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == dinoSpriteNode.physicsBody && contact.bodyB == groundNode.physicsBody) ||
            (contact.bodyB == dinoSpriteNode.physicsBody && contact.bodyA == groundNode.physicsBody) {
            canJump = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA == dinoSpriteNode.physicsBody && contact.bodyB == groundNode.physicsBody) ||
            (contact.bodyB == dinoSpriteNode.physicsBody && contact.bodyA == groundNode.physicsBody) {
            canJump = false
        } else {
            endGame()
        }
    }
    
    func logger() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            NSLog("Sprite at: %f, %f", self.dinoSpriteNode.position.x, self.dinoSpriteNode.position.y)
            self.logger()
        })
    }
    
    
}

