//
//  HostCellView.swift
//  MQTTAnalyzer
//
//  Created by Philipp Arndt on 2019-11-17.
//  Copyright © 2019 Philipp Arndt. All rights reserved.
//

import SwiftUI

enum HostCellViewSheetType {
	case edit
	case login
}

struct HostCellView: View {
	@EnvironmentObject var model: RootModel
	@ObservedObject var host: Host
	@ObservedObject var messageModel: MessageModel
	
	@State var sheetPresented = false
	@State var sheetType = HostCellViewSheetType.edit
	
	var connectionColor: Color {
		host.connected ? .green : .gray
	}
	
	var body: some View {
		NavigationLink(destination: TopicsView(model: messageModel, host: host, dialogPresented: host.needsAuth)) {
			HStack {
				VStack(alignment: .leading) {
					Text(host.aliasOrHost)
					Spacer()
					Group {
						Text(host.hostname)
						Text(host.topic)
					}
					.font(.footnote)
					.foregroundColor(.secondary)
				}
				
				Spacer()
				
				if host.connected || host.connecting {
					Text("\(messageModel.messageCount)")
						.font(.system(size: 14, design: .monospaced))
						.foregroundColor(.secondary)
					
					Image(systemName: "circle.fill")
						.font(.subheadline)
						.foregroundColor(connectionColor)
				}
			}
			.contextMenu {
				MenuButton(title: "Edit", systemImage: "pencil.circle", action: editHost)
				if host.connected || host.connecting {
					MenuButton(title: "Disconnect", systemImage: "stop.circle", action: disconnect)
				}
				else {
					MenuButton(title: "Connect", systemImage: "play.circle", action: connect)
				}
			}
		}.sheet(isPresented: $sheetPresented, onDismiss: cancelEditCreation, content: {
			if self.sheetType == .login {
				LoginDialogView(loginCallback: self.login, host: self.host, data: self.createLoginDataModel())
			}
			else {
				EditHostFormModalView(closeHandler: self.cancelEditCreation,
					root: self.model,
					hosts: self.model.hostsModel,
					original: self.host,
					host: self.transformHost(),
					auth: self.host.auth)
			}
		})
	}
	
	func transformHost() -> HostFormModel {
		return HostFormModel(alias: host.alias,
							 hostname: host.hostname,
							 port: "\(host.port)",
							 topic: host.topic,
							 qos: host.qos,
							 username: host.username,
							 password: host.password,
							 certServerCA: host.certServerCA,
							 certClient: host.certClient,
							 certClientKey: host.certClientKey,
							 certClientKeyPassword: host.certClientKeyPassword,
							 clientID: host.clientID,
							 limitTopic: "\(host.limitTopic)",
							 limitMessagesBatch: "\(host.limitMessagesBatch)")
	}
	
	func editHost() {
		sheetType = .edit
		sheetPresented = true
	}
	
	func disconnect() {
		host.disconnect()
	}
	
	func connect() {
		if self.host.needsAuth {
			sheetType = .login
			sheetPresented = true
		}
		else {
			model.connect(to: host)
		}
	}
	
	func login() {
		sheetType = .login
		sheetPresented = false
		model.connect(to: self.host)
	}
	
	func createLoginDataModel() -> LoginData {
		return LoginData(username: host.username, password: host.password)
	}
	
	func cancelEditCreation() {
		sheetPresented = false
	}
}
