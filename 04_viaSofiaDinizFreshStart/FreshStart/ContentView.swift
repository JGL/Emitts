//
//  ContentView.swift
//  FreshStart
//
//  Created by Joel Lewis on 25/09/2023.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @ObservedObject var arViewModel : ARViewModel = ARViewModel()
    
    var visionRequests = [VNRequest]()
    
    var body: some View {
        ARViewContainer(arViewModel: arViewModel)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        arViewModel.startSessionDelegate()
        return arViewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

#Preview {
    ContentView()
}
