//
//  NewHostFormModalView.swift
//  MQTTAnalyzer
//
//  Created by Philipp Arndt on 2019-11-22.
//  Copyright © 2019 Philipp Arndt. All rights reserved.
//

import SwiftUI
import swift_petitparser

// MARK: Create Host
struct NewHostFormModalView: View {
	let closeHandler: () -> Void
	let root: RootModel
	var hosts: HostsModel
	
	@State private var host: HostFormModel = HostFormModel()
	@State private var auth: HostAuthenticationType = .none
	
	var disableSave: Bool {
		return HostFormValidator.validateHostname(name: host.hostname) == nil
			|| HostFormValidator.validatePort(port: host.port) == nil
			|| HostFormValidator.validateMaxTopic(value: host.limitTopic) == nil
			|| HostFormValidator.validateMaxMessagesBatch(value: host.limitMessagesBatch) == nil
	}
	
	var body: some View {
		NavigationView {
			EditHostFormView(host: $host, auth: $auth)
				.font(.caption)
				.navigationBarTitle(Text("New host"))
				.navigationBarItems(
					leading: Button(action: cancel) {
						Text("Cancel")
						
					}.buttonStyle(ActionStyleLeading()),
					
					trailing: Button(action: save) {
						Text("Save")
					}.buttonStyle(ActionStyleTrailing()).disabled(disableSave)
			)
		}
	}
	
	func save() {
		let newHostname = HostFormValidator.validateHostname(name: host.hostname)
		let port = HostFormValidator.validatePort(port: host.port)
		
		if port == nil || newHostname == nil {
			return
		}
		
		let newHost =  Host()
		newHost.alias = host.alias
		newHost.hostname = newHostname!
		newHost.qos = host.qos
		newHost.auth = self.auth
		newHost.port = port!
		newHost.topic = host.topic
		newHost.clientID = host.clientID
		newHost.auth = self.auth

		if self.auth == .usernamePassword {
			newHost.username = host.username
			newHost.password = host.password
		}
		else if self.auth == .certificate {
			newHost.certServerCA = host.certServerCA
			newHost.certClient = host.certClient
			newHost.certClientKey = host.certClientKey
			newHost.certClientKeyPassword = host.certClientKeyPassword
		}
		
		hosts.hosts.append(newHost)
		
		root.persistence.create(newHost)
		
		closeHandler()
	}
	
	func cancel() {
		closeHandler()
	}
}
