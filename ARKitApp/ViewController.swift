//
//  ViewController.swift
//  ARKitApp
//
//  Created by zeynep tokcan on 18.08.2020.
//  Copyright © 2020 zeynep tokcan. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet var arView: ARView!
    
    // MARK: - Override Functions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARView()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Private Functions
    private func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    private func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation ], for: entity)
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
    
    // MARK: - Objc Function
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "Circle", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else { print("Object placement failed") }
    }
}

// MARK: - Extension ARSessionDelegate
extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "Circle" {
                placeObject(named: anchorName, for: anchor )
            }
        }
    }
}
