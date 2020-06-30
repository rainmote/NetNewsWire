//
//  IconImageView.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 6/29/20.
//  Copyright © 2020 Ranchero Software. All rights reserved.
//

import SwiftUI

struct IconImageView: View {
	
	var iconImage: IconImage
	
    var body: some View {
		#if os(macOS)
		return Image(nsImage: iconImage.image)
			.resizable()
			.scaledToFit()
			.frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
			.cornerRadius(4)
		#endif
		#if os(iOS)
		return Image(uiImage: iconImage.image)
			.resizable()
			.scaledToFit()
			.frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
			.cornerRadius(4)
		#endif
    }
}

struct IconImageView_Previews: PreviewProvider {
    static var previews: some View {
		IconImageView(iconImage: IconImage(AppAssets.faviconTemplateImage))
    }
}
