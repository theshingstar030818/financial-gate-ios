Financial Gate
----------------------------------


#####bitcoin done right

the simplest and most secure bitcoin wallet on any platform 



#####the first standalone iOS bitcoin wallet:

Unlike other iOS bitcoin wallets, breadwallet is a real standalone bitcoin
client. There is no server to get hacked or go down, so you can always access
your money. Using
[SPV](https://en.bitcoin.it/wiki/Thin_Client_Security#Header-Only_Clients)
mode, breadwallet connects directly to the bitcoin network with the fast
performance you need on a mobile device.

#####the next step in wallet security:

financialGate is designed to protect you from malware, browser security holes,
*even physical theft*. With AES hardware encryption, app sandboxing, keychain
and code signatures, financialGate represents a significant security advance over
web and desktop wallets, and other mobile platforms.

#####beautiful simplicity:

Simplicity is financialGate's core design principle. A simple backup phrase is
all you need to restore your wallet on another device if yours is ever lost or
broken.  Because financialGate is  
[deterministic](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki),
your balance and transaction history can be recovered from just your backup
phrase.



#####features:

- ["simplified payment verification"](https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki) for fast mobile performance
- no server to get hacked or go down
- single backup phrase that works forever
- private keys never leave your device
- import [password protected](https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki) paper wallets
- ["payment protocol"](https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki) payee identity certification

#####URL scheme:

financialGate supports the [x-callback-url](http://x-callback-url.com)
specification with the following URLs:

```
bread://x-callback-url/address?x-success=myscheme://myaction
```

this will callback with the current wallet receive address: `myscheme://myaction?address=1XXXX`

the following will ask the user to authorize copying a list of their wallet
addresses to the clipbaord before calling back:

```
bread://x-callback-url/addresslist?x-success=myscheme://myaction
```

#####WARNING:

installation on jailbroken devices is strongly discouraged

Any jailbreak app can grant itself access to every other app's keychain data
and rob you by self-signing as described [here](http://www.saurik.com/id/8)
and including `<key>application-identifier</key><string>*</string>` in its
.entitlements file.

financialGate is open source and available under the terms of the MIT license.
Source code is available at https://github.com/askari01/breadwallet
