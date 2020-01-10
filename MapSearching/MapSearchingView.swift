//
//  MapSearchingView.swift
//  MapSearching
//
//  Created by Alexander Römer on 10.01.20.
//  Copyright © 2020 Alexander Römer. All rights reserved.
//

import SwiftUI

struct MapSearchingView: View {
    
    @ObservedObject private var vm = MapSearchingViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            
            MapViewContainer(annotations: vm.annotations, selectedMapItem: vm.selectedMapItem, currentLocation: vm.currentLocation)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                
                HStack {
                    TextField("Search terms", text: $vm.searchQuery, onCommit: {
                        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
                    })
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                }
                .padding()
                
                if vm.isSearching {
                    Text("Searching...")
                }
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(vm.mapItems, id: \.self) { item in
                            Button(action: {
                                print(item.name ?? "")
                                self.vm.selectedMapItem = item
                            }, label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "")
                                        .font(.headline)
                                    Text(item.placemark.title ?? "")
                                }
                            })
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .shadow(radius: 5)
                
                Spacer()
                    .frame(height: vm.keyboardHeight)
            }
        }
        
    }
    
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
