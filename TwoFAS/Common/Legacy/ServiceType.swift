//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import Foundation

enum ServiceType: String, Equatable, CaseIterable {
    case amazon
    case tibia
    case vk
    case wordpress
    case ifttt
    case ovh
    case zoho
    case digitalOcean
    case zendesk
    case teamViewer
    case stripe
    case sourceForge
    case hootsuite
    case slack
    case braintree
    case bitpay
    case google
    case TwoFASSecret
    case TwoFASMobileSecret
    case ea
    case blockchain
    case buffer
    case cloudflare
    case mailChimp
    case qnap
    case dnsMadeEasy
    case gitlab
    case github
    case evernote
    case goDaddy
    case kickstarter
    case dropbox
    case heroku
    case lastPass
    case hetzner
    case minergate
    case poloniex
    case bittrex
    case bitbucket
    case beamPro
    case facebook
    case angelList
    case microsoft
    case skrill
    case sentry
    case opskins
    case binance
    case bitbay
    case bitskins
    case btcMarkets
    case coinbase
    case cryptoMKT
    case discord
    case niceHashBuying
    case niceHashLogin
    case niceHashWithdraw
    case D00M79
    case manual
    case unknown
    case epicGames
    case xero
    case ubisoft
    case mega
    case snapchat
    case instagram
    case netSuite
    case humbleBundle
    case firefox
    case nintendo
    case kuCoin
    case myob
    case litebit_eu
    case twitter
    case bitcoinMeester
    case atlantiss
    case autodesk
    case bitfinex
    case preceda
    case jura
    case blockchains
    case coinsquare_io
    case bitvavo
    case coindeal_io
    case brave
    case onelogin
    case sofi
    case trello
    case uphold
    case fintegri
    case wordfence
    case jagex
    case gamdom
    case payPal
    case karatbit
    case devexMail
    case reddit
    case logingov
    case uscis
    case okonto
    case freshDesk
    case hubSpot
    case chargebee
    case discourse
    case linkedIn
    case onePassword
    case namecheap
    case shopify
    case jamfNow
    case kraken
    case bitMax
    case gateIo
    case upwork
    case protonMail
    case bitriseIo
    case adobe
    case nvidia
    case synology
    case twitch
    case bitwarden
    case samsung
    case uber
    case zoom
    case activision
    case homeAssistant
    case nordAccount
    case twentyI
    case ascendEx
    case backBlaze
    case bitpanda
    case gmx
    case jetBrains
    case joomla
    case nextcloud
    case opera
    case tebex
    case tumblr
    case unity
    case xing
    case telderi
    case tastyworks
    case parsec
    case pulseway
    case uptimeRobot
    case oracle
    case roboForm
    case razer
    case adGuard
    case ubiquiti
    case hurricaneElectric
    case box
    case gitea
    case gogs
    case wikijs
    case intuit
    case sony
    case drupal
    case robinhood
    case kayako
    case bybit
    case docker
    case choice
    case wyze
    case fritzbox
    case cryptoCom
    case coinList
    case plex
    case hackTheBox
    case squareEnix
    case arenaNet
    case fSecure
    case phpMyAdmin
    case ring
    case trimble
    case rockstarGames
    case salesForce
    case ftxUS
    case sophosSFOS
    case synologyDSM
    case ftx
    case binanceUS
    case patreon
    case bitkub
    case coinDCX
    case coinSpot
    case roblox
    case wazirX
    case mongoDB
    case governmentGateway
    case whiteBIT
    case arbeitsagentur
    case aws
    case enZona
    case paxful
    case questrade
    case tMobile
    case tesla
    case windscribe
    case yahoo
    case proton
    case grammarly
    case steam
    case tikTok
    case vimeo
    case idme

    case norton
    case surfshark
    case nextDNS
    case pCloud
    case trueNAS
    case openVPN
    case anyDesk
    case proxmox
    case kaspersky
    case ionos
    case pyPI
    case tradingView
    case coursera
    case figma
    case avast
    case okx
    case nexo
    case linusTechTips
    case noIP
    case trendMicro
    case xda
    case webDE
    case atlassian
    case cisco
    case wargaming
    case allegro
    case faceit
    case etsy
    case cashApp
    case mercadoLibre
    case mercadoLivre
    
    case bitfinex_fromName
    case preceda_fromName
    case jura_fromName
    case cosmicPvP_fromName
    case blockchains_fromName
    case drupal_fromName
    case coinsquare_io_fromName
    case bitvavo_fromName
    case coindeal_io_fromName
    case hmrc_fromName
    case brave_fromName
    case onelogin_fromName
    
    static func createFromValue(_ name: String) -> ServiceType {
        let service = ServiceType(rawValue: name)
        return service ?? .unknown
    }
}
