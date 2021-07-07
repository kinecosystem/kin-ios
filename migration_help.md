# Migrating from 0.x to 1.x

## Kin Storage
Prior to version 1.0.0, Kin accounts were stored inside directories specific to the environment being used (mainnet, testnet, kin2, kin3, etc). This has been deprecated in version 1.0.0. The new default is for Kin storage to reside at `~/Documents/kin_storage`. Legacy apps wishing to maintain support for their existing users are advised to use the `storagePath` parameter when initializing their `KinEnvironment` to provide a custom storage path pointing to where previous versions of the Kin SDK stored its data.

### Sample code for migrating apps
```
var customPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
customPath.appendPathComponent("kin_storage")
customPath.appendPathComponent("env")
customPath.appendPathComponent("[ENV_ID]")
let environment = KinEnvironment.Agora.mainNet(appInfoProvider: yourAppInfoProvider, storagePath: customPath)
```

#### Kin3 apps
Replace `[ENV_ID]` in the above example with `9DKMS82DC5KMSRJ5EGG3M824CLHMARB2CLP20CHG64S0====`

#### Kin2 apps
Replace `[ENV_ID]` in the above example with `A1QM4R39CCG4ER3FC9GMO82BD5N20HB3DTPNISRKCLMI0JJ5EHRMUSJB40TI0IJLDPII0CHG64S0====`

#### Other
The `ENV_ID` referenced above is the base32hex encoding of the KinNetwork.Id your app was using prior to updating to 1.x. Listed above are the encodings for Kin3 mainnet and Kin2 mainnet, but if you had a different configuration, you can use a base32hex encoder to generate the appropriate string, or check an existing device to find the precise storage location it was using.

