import { useState, useEffect } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
  Image,
  TextInput,
  Switch,
  Alert,
  TouchableOpacity,
} from 'react-native';
import Paymob, {
  PaymentStatus,
  type PaymentResponse,
} from 'paymob-reactnative';
import PaymobEmbeddedView from './PaymobEmbeddedView';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<'home' | 'embedded'>('home');
  const [appName, setAppName] = useState<string>('');
  const [isSaveCardEnabled, setSaveCardEnabled] = useState<boolean>(true);
  const [isShowConfirmationPage, setShowConfirmationPage] =
    useState<boolean>(true);
  const [isSaveCardDefault, setSaveCardDefault] = useState<boolean>(false);

  const [buttonBackgroundColor, setButtonBackgroundColor] =
    useState<string>('#000000');
  const [buttonTextColor, setButtonTextColor] = useState<string>('#FFFFFF');

  const colors = ['#000000', '#FFFFFF', '#FF0000', '#00FF00', '#0000FF'];

  const base64Image = `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`;

  useEffect(() => {
    Paymob.setSdkListener((response: PaymentResponse) => {
      // Handle the transaction status
      switch (response.status) {
        case PaymentStatus.SUCCESS:
          requestAnimationFrame(() => {
            Alert.alert('Payment result', PaymentStatus.SUCCESS);
          });
          break;
        case PaymentStatus.FAIL:
          requestAnimationFrame(() => {
            Alert.alert('Payment result', PaymentStatus.FAIL);
          });
          break;
        case PaymentStatus.PENDING:
          requestAnimationFrame(() => {
            Alert.alert('Payment result', PaymentStatus.PENDING);
          });
          break;
      }
    });

    return () => {
      Paymob.removeSdkListener();
    };
  }, []);

  // Show PaymobEmbeddedView if currentScreen is 'embedded'
  if (currentScreen === 'embedded') {
    return <PaymobEmbeddedView onBack={() => setCurrentScreen('home')} />;
  }

  return (
    <View style={styles.container}>
      <View style={{ flex: 1, justifyContent: 'center' }}>
        <Image
          style={{
            height: 50,
            resizeMode: 'contain',
            marginBottom: 48,
          }}
          source={{ uri: `data:image/png;base64,${base64Image}` }}
        />
        <Text style={{ fontSize: 20, fontWeight: 'bold', marginBottom: 32 }}>
          Customizations
        </Text>
        <TextInput
          style={{ marginBottom: 32, fontSize: 20 }}
          onChangeText={(text: string) => {
            setAppName(text);
            Paymob.setAppName(text);
          }}
          value={appName}
          placeholder="Enter your app name"
        />

        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 32,
          }}
        >
          <Text style={{ fontSize: 20 }}>Show save card</Text>
          <Switch
            style={{ marginStart: 16 }}
            onValueChange={(flag: boolean) => {
              setSaveCardEnabled(flag);
              Paymob.setShowSaveCard(flag);
            }}
            value={isSaveCardEnabled}
          />
        </View>

        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 32,
          }}
        >
          <Text style={{ fontSize: 20 }}>Show confirmation page</Text>
          <Switch
            style={{ marginStart: 16 }}
            onValueChange={(flag: boolean) => {
              setShowConfirmationPage(flag);
              Paymob.setShowConfirmationPage(flag);
            }}
            value={isShowConfirmationPage}
          />
        </View>

        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 32,
          }}
        >
          <Text style={{ fontSize: 20 }}>Save card default</Text>
          <Switch
            style={{ marginStart: 16 }}
            onValueChange={(flag: boolean) => {
              setSaveCardDefault(flag);
              Paymob.setSaveCardDefault(flag);
            }}
            value={isSaveCardDefault}
          />
        </View>

        <Text style={{ fontSize: 20 }}>Button background color</Text>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 24,
          }}
        >
          {colors.map((color, index) => (
            <TouchableOpacity
              key={index}
              style={{
                width: 50,
                height: 40,
                padding: 4,
                marginEnd: 16,
                marginTop: 16,
                borderWidth: buttonBackgroundColor === color ? 3 : 0,
                borderColor: '#000000',
                borderRadius: 10,
              }}
              onPress={() => {
                Paymob.setButtonBackgroundColor(color);
                setButtonBackgroundColor(color);
              }}
            >
              <View
                style={{
                  width: '100%',
                  height: '100%',
                  borderRadius: 6,
                  backgroundColor: color,
                }}
              />
            </TouchableOpacity>
          ))}
        </View>

        <Text style={{ fontSize: 20 }}>Button text color</Text>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 48,
          }}
        >
          {colors.map((color, index) => (
            <TouchableOpacity
              key={index}
              style={{
                width: 50,
                height: 40,
                padding: 4,
                marginEnd: 16,
                marginTop: 16,
                borderWidth: buttonTextColor === color ? 3 : 0,
                borderColor: '#000000',
                borderRadius: 10,
              }}
              onPress={() => {
                Paymob.setButtonTextColor(color);
                setButtonTextColor(color);
              }}
            >
              <View
                style={{
                  width: '100%',
                  height: '100%',
                  borderRadius: 6,
                  backgroundColor: color,
                }}
              />
            </TouchableOpacity>
          ))}
        </View>

        <Button
          onPress={() => {
            Paymob.presentPayVC(
              'egy_csk_test_470ff99341ee584adf6ee587f7d199be',
              'egy_pk_test_jbtqjbZUZpcvIjvMSHrAXVQ2dFVsS0xi'
            );
          }}
          title="Present Paymob"
        />

        <View style={{ height: 16 }} />

        <Button
          onPress={() => setCurrentScreen('embedded')}
          title="Go to Paymob Embedded View"
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'whitesmoke',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
