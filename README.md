# Paymob for React Native

Paymob runs millions of transactions for different business sizes across the Middle East and Africa. Start using Paymob’s solutions and API’s to accept and send payments for your online business now.

To learn more about Paymob’s offerings and capabilities, visit [Paymob.com](https://www.paymob.com).

## Installation

To get started with the `paymob-reactnative` package, follow these steps:

- **Install the Package**

  Open your terminal, navigate to your React Native project directory, and install the `paymob-reactnative` package using npm:

  ```bash
  npm install paymob-reactnative@https://github.com/PaymobAccept/paymob-reactnative-sdk.git
  ```

  If you prefer using Yarn, you can run:

  ```bash
  yarn add paymob-reactnative@https://github.com/PaymobAccept/paymob-reactnative-sdk.git
  ```

  ### iOS

- **Install CocoaPods for iOS**

  If you are developing for iOS, you will need to install CocoaPods to manage your project's dependencies. Run the following commands:

  ```bash
  cd ios && pod install && cd ..
  ```

  This step ensures that the necessary native modules are linked correctly in your iOS project.

  **Important Notice:** If you encounter an issue with the native iOS SDK, you may need to create a new blank Swift file in Xcode. After creating the blank file, be sure to click on `Create Bridging Header` when prompted.

  ### Android

- Append the following snippet to your **project-level** `build.gradle` file.
  ```java
  allprojects {
      repositories {
          maven {
              url = rootProject.projectDir.toURI().resolve("../node_modules/paymob-reactnative/android/libs")
          }
          maven {
              url = uri("https://jitpack.io")
          }
      }
  }
  ```
- Add the following snippet to your **app-level** `build.gradle` file.
  ```java
  android {
      buildFeatures { dataBinding = true }
  }
  ```

## Using Paymob

To begin using the Paymob SDK in your React Native application, start by importing the module in your component:

```javascript
import Paymob, {
  PaymentStatus,
  FailureCallBackVersion,
} from 'paymob-reactnative';
```

### SDK Customization

You can customize the Paymob SDK to match your app's branding and user experience by calling the following functions:

```javascript
Paymob.setAppIcon(base64Image); // Set your merchant logo using a base64 encoded image
Paymob.setAppName('Paymob SDK'); // Customize merchant app name displayed in the Paymob interface
Paymob.setButtonTextColor('#FFFFFF'); // Set the text color of buttons in the SDK
Paymob.setButtonBackgroundColor('#000000'); // Set the background color of buttons in the SDK
Paymob.setShowSaveCard(true); // Enable the option for users to save their cards
Paymob.setSaveCardDefault(true); // Set saved card option as default for transactions
Paymob.setShowConfirmationPage(true); // Show confirmation page upon payment
```

These customization options allow you to tailor the Paymob SDK interface to align with your brand identity.

### Important Notice

**Please ensure that all SDK customizations are completed before calling `Paymob.presentPayVC()`. Failing to do so may result in the payment interface not reflecting your desired branding and settings.**

### Adding a Listener

To handle payment results, register a listener with `Paymob.setSdkListener`. The listener receives a response object each time the full-screen payment flow started by `Paymob.presentPayVC()` finishes, and it is the single entry point for the success, failure, cancellation, and pending outcomes:

```javascript
Paymob.setSdkListener((response) => {
  switch (response.status) {
    case PaymentStatus.SUCCESS:
      // Handle successful payment (transaction data is in response.details)
      break;
    case PaymentStatus.FAIL:
      // Handle failed payment (the reason is in response.message)
      break;
    case PaymentStatus.CANCELLED:
      // Handle a payment cancelled by the user
      break;
    case PaymentStatus.PENDING:
      // Handle pending payment status
      break;
  }
});
```

The `response` object has the following fields:

| Field | Type | Description |
| --- | --- | --- |
| `status` | `string` | One of `PaymentStatus.SUCCESS` (`'Success'`), `PaymentStatus.FAIL` (`'Fail'`), `PaymentStatus.CANCELLED` (`'Cancelled'`), or `PaymentStatus.PENDING` (`'Pending'`). |
| `details` | `object` | Transaction data returned by the native SDK for a successful payment. On Android it is also present, as an empty object, for the other statuses; on iOS it is omitted. |
| `message` | `string` | The failure reason. Only present when `status` is `'Fail'`. |

Keep the following in mind:

- Only one listener is active at a time. Calling `setSdkListener` again replaces the previous listener, and `Paymob.removeSdkListener()` removes it (for example, when your component unmounts).
- Register the listener before calling `Paymob.presentPayVC()`. On Android, results are only delivered while a listener is registered.
- The native module delivers results through the `onTransactionStatus` event. `setSdkListener` subscribes to it for you, so you do not need to use `NativeEventEmitter` directly.

### Handling Payment Failures

A failed payment is reported through the same listener, as a response with `status` equal to `PaymentStatus.FAIL`. There is no separate failure API for the full-screen flow.

**Callback parameters**

- `response.status`: `'Fail'` (`PaymentStatus.FAIL`).
- `response.message`: a string describing why the payment failed, as reported by the native SDK.

**Failure callback version**

You can select the failure callback version used by the native SDK with `Paymob.setFailureCallbackVersion`:

```javascript
Paymob.setFailureCallbackVersion(FailureCallBackVersion.V2);
```

- Supported values are `FailureCallBackVersion.V1` and `FailureCallBackVersion.V2`. The strings `'V1'` and `'V2'` are also accepted (case-insensitive); any other value falls back to `V1`.
- Call it before `Paymob.presentPayVC()`, like the other SDK customizations.
- It applies to the full-screen flow started by `Paymob.presentPayVC()`. The embedded view does not use it.
- The React Native bridge always delivers the failure reason to your listener as `response.message`. What differs between `V1` and `V2` is defined by the native SDKs and is not documented in this package.

**Complete example**

```javascript
import React, { useEffect } from 'react';
import { Alert, Button, View } from 'react-native';
import Paymob, {
  PaymentStatus,
  FailureCallBackVersion,
} from 'paymob-reactnative';

const showAlert = (title, message) =>
  requestAnimationFrame(() => Alert.alert(title, message));

export default function CheckoutScreen({ clientSecret, publicKey }) {
  useEffect(() => {
    Paymob.setSdkListener((response) => {
      switch (response.status) {
        case PaymentStatus.SUCCESS:
          console.log('Payment succeeded', response.details);
          break;
        case PaymentStatus.FAIL:
          showAlert('Payment failed', response.message ?? 'Unknown error');
          break;
        case PaymentStatus.CANCELLED:
          showAlert('Payment cancelled');
          break;
        case PaymentStatus.PENDING:
          showAlert('Payment pending');
          break;
      }
    });

    return () => {
      Paymob.removeSdkListener();
    };
  }, []);

  const pay = () => {
    Paymob.setFailureCallbackVersion(FailureCallBackVersion.V2);
    Paymob.presentPayVC(clientSecret, publicKey);
  };

  return (
    <View>
      <Button title="Pay" onPress={pay} />
    </View>
  );
}
```

### Handling Cancellation

Cancellation is supported and is reported through the same listener, as a response with `status` equal to `PaymentStatus.CANCELLED` (`'Cancelled'`). It is emitted when the native SDK reports that the payment was cancelled.

- **Payload:** only `response.status`. There is no `message`, and `details` is empty (an empty object on Android, omitted on iOS).

```javascript
Paymob.setSdkListener((response) => {
  if (response.status === PaymentStatus.CANCELLED) {
    // The payment was cancelled, for example return the user to the cart
  }
});
```

For the embedded view, cancellation is delivered through the `onCancelled` prop instead. See [Embedded View](#embedded-view).

### Invoking the SDK

After configuring the SDK, you can invoke the Paymob payment interface with the following code:

```javascript
Paymob.presentPayVC('CLIENT_SECRET', 'PUBLIC_KEY');
```

This function call opens the Paymob payment interface, allowing users to complete their transactions securely. Make sure to replace `'CLIENT_SECRET'` and `'PUBLIC_KEY'` with your actual credentials.

## Embedded View

Besides the full-screen flow started by `Paymob.presentPayVC()`, the SDK can render the card checkout inside your own screen through the native `PaymobCheckoutView` component. This keeps the customer inside your app UI while card entry and payment processing happen in an embedded native view.

The embedded view is available on both iOS and Android. It uses the same native SDKs and the same installation steps described above; no additional setup is required.

**Important:** the package does not export a JavaScript wrapper for the embedded view. You obtain the component with `requireNativeComponent('PaymobCheckoutView')` and drive it with two native commands, `configure` and `setPaymentKeys`, exactly as the [example app](example/src/PaymobEmbeddedView.tsx) does. The embedded view is not covered by the package's TypeScript declarations.

### Import and Usage

Register the native component once, at module scope, then render it and keep a ref to it:

```javascript
import { requireNativeComponent } from 'react-native';

const PaymobCheckoutView = requireNativeComponent('PaymobCheckoutView');
```

### Props

| Prop | Type | Description |
| --- | --- | --- |
| `style` | `StyleProp<ViewStyle>` | Standard view style. See [Layout and Styling](#layout-and-styling). |
| `onSuccess` | `(event) => void` | Called when the payment succeeds. `event.nativeEvent` contains the transaction details. |
| `onFailure` | `(event) => void` | Called when the payment fails. `event.nativeEvent.error` contains the failure reason. |
| `onCancelled` | `(event) => void` | Called when the payment is cancelled. `event.nativeEvent` is an empty object. |
| `onPending` | `(event) => void` | Called when the payment is pending. `event.nativeEvent` is an empty object. |

Note that the embedded view reports the failure reason as `event.nativeEvent.error`, whereas the full-screen listener reports it as `response.message`.

### Commands

Commands are sent to the view with `UIManager.dispatchViewManagerCommand(findNodeHandle(ref.current), commandName, args)`. Send each command once, using the command name as a string; this works on both platforms.

| Command | Arguments | Description |
| --- | --- | --- |
| `configure` | `[config]` | Applies the embedded view configuration. Send it once after the view has mounted and before setting the payment keys. |
| `setPaymentKeys` | `[{ publicKey, clientSecret }]` | Provides the payment keys used by the embedded checkout. |

### Configuration

The `configure` command takes a single configuration object. All fields are optional:

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `showAddNewCard` | `boolean` | `true` | Show or hide the "Add new card" option. |
| `showSaveCard` | `boolean` | `true` | Show or hide the save card option. |
| `saveCardByDefault` | `boolean` | iOS: `false`, Android: `true` | Pre-check the save card option. The default differs between platforms, so set it explicitly. |
| `payFromOutside` | `boolean` | `false` | Not currently usable from React Native. See [Limitations](#limitations-of-the-embedded-view). |
| `uiCustomization` | `string` | none | Optional UI customization, passed to the native SDK as a JSON-encoded string. Omit it to use the default appearance. The supported keys are defined by the native SDKs. |

The full-screen customization functions (`Paymob.setAppName`, `Paymob.setButtonBackgroundColor`, and so on) apply to `Paymob.presentPayVC()` only and do not affect the embedded view.

### Payment Keys

Your backend creates the payment intention with your **secret key** and returns the `publicKey` and `clientSecret` to the app. Never put your secret key inside the app. Once you have the keys, send them to the view:

```javascript
UIManager.dispatchViewManagerCommand(
  findNodeHandle(checkoutRef.current),
  'setPaymentKeys',
  [{ publicKey, clientSecret }]
);
```

### Layout and Styling

- The height of the embedded view is dynamic. The native view reports its content height to React Native's layout on both platforms, so the view grows and shrinks as its content changes (for example, when the customer opens the card form). Do not set a fixed `height` on it, because that would override the reported height.
- Give the view the full available width, for example `width: '100%'` (or `alignSelf: 'stretch'`).
- Because the height can change, place the view inside a `ScrollView` when the screen has other content around it.

### Complete Example

```javascript
import React, { useEffect, useRef } from 'react';
import {
  ScrollView,
  StyleSheet,
  Text,
  UIManager,
  findNodeHandle,
  requireNativeComponent,
} from 'react-native';

const PaymobCheckoutView = requireNativeComponent('PaymobCheckoutView');

const sendCommand = (ref, commandName, args) => {
  const handle = findNodeHandle(ref.current);
  if (handle) {
    UIManager.dispatchViewManagerCommand(handle, commandName, args);
  }
};

export default function EmbeddedCheckoutScreen({ publicKey, clientSecret }) {
  const checkoutRef = useRef(null);

  // 1. Configure the view once it has mounted
  useEffect(() => {
    sendCommand(checkoutRef, 'configure', [
      {
        showAddNewCard: true,
        showSaveCard: true,
        saveCardByDefault: false,
        payFromOutside: false,
      },
    ]);
  }, []);

  // 2. Provide the keys returned by your backend
  useEffect(() => {
    if (publicKey && clientSecret) {
      sendCommand(checkoutRef, 'setPaymentKeys', [{ publicKey, clientSecret }]);
    }
  }, [publicKey, clientSecret]);

  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Text style={styles.title}>Checkout</Text>

      <PaymobCheckoutView
        ref={checkoutRef}
        style={styles.checkout}
        onSuccess={(event) => {
          console.log('Payment succeeded', event.nativeEvent);
        }}
        onFailure={(event) => {
          console.log('Payment failed', event.nativeEvent.error);
        }}
        onCancelled={() => {
          console.log('Payment cancelled');
        }}
        onPending={() => {
          console.log('Payment pending');
        }}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  content: { padding: 16 },
  title: { fontSize: 18, fontWeight: 'bold', marginBottom: 16 },
  checkout: { width: '100%' },
});
```

### Limitations of the Embedded View

- **No external payment trigger.** The native SDK supports a `payFromOutside` mode, but the React Native bridge does not expose a command to start the payment from your own button. Leave `payFromOutside` as `false` and use the pay button rendered inside the embedded view.
- **No height callback.** The dynamic height is handled internally; there is no `onHeightChanged` prop.
- **No single result callback.** Results are delivered through the four `onSuccess`, `onFailure`, `onCancelled`, and `onPending` props.
- **No dispose method.** No explicit release command is exposed.
- **Android:** the `configure` command requires the current Activity to be an `androidx.activity.ComponentActivity`, which the default `ReactActivity` is.
- **Architecture:** the embedded view is implemented as a legacy native view manager, and the example app runs with the New Architecture disabled. Behavior with the New Architecture enabled is not documented here.

Here’s the updated explanation with a revised first sentence and the inclusion of the repository cloning step:

## Example App

To explore the SDK or test its features, you can clone the repository and run the example app by following these steps:

1. **Clone the Repository**  
   Clone the repository to your local machine.

2. **Install Dependencies**  
   Navigate to the project directory and install the required dependencies using Yarn. Run:

   ```bash
   yarn
   ```

3. **Run the Example App**  
   You can run the example app for both iOS and Android platforms:

   - To run the app on **iOS**, use the following command:

     ```bash
     yarn example ios
     ```

   - To run the app on **Android**, use this command:

     ```bash
     yarn example android
     ```

By following these steps, you can explore the functionality of the SDK in the example app.

## Documentation

For more detailed information about the supported APIs, usage guidelines, and advanced features, please refer to our comprehensive [**Documentation**](https://developers.paymob.com/). Here, you will find examples, best practices, and troubleshooting tips to help you make the most out of the Paymob SDK.
