//
//  ParticleSystem.swift
//  VisualisingGestures
//
//  Created by Joel Lewis on 29/08/2023.
//

import SwiftUI

class ParticleSystem{
    var particles = Set<Particle>()
    var centre = UnitPoint.center
    
    func update(date: TimeInterval, currentHandAction: HandAction){
        let deathDate = date - 1
        
        for particle in particles {
            if particle.creationDate < deathDate{
                particles.remove(particle)
            }
        }
        
        let newParticle = Particle(x: centre.x, y: centre.y, handAction: currentHandAction)
        particles.insert(newParticle)
    }
}
