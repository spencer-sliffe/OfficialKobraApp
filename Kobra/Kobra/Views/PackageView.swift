//
//  PackageView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/7/23.
//

import SwiftUI

struct PackageView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.packages, id: \.id) { package in
                Text(package.medal)
            }
            .navigationTitle("Packages")
            .navigationBarItems(trailing: Button(action: {
                //add
            }, label: {
                Image(systemName: "plus")
            }))
        }
    }
}

struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView().environmentObject(DataManager())
    }
}
