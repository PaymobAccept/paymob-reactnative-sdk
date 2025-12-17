import React, { useEffect, useRef, useState } from 'react';
import {
    View,
    Text,
    Button,
    StyleSheet,
    ActivityIndicator,
    requireNativeComponent,
    UIManager,
    findNodeHandle,
    Platform,
} from 'react-native';

import type { ViewStyle } from 'react-native';

interface PaymobEmbeddedViewProps {
    onBack: () => void;
}

type PaymobCheckoutViewProps = {
    style: ViewStyle;
    onSuccess?: (event: any) => void;
    onFailure?: (event: any) => void;
    onPending?: (event: any) => void;
};

const ComponentName = 'PaymobCheckoutView';

const PaymobCheckoutView =
    requireNativeComponent<PaymobCheckoutViewProps>(ComponentName);

export default function PaymobEmbeddedView({ onBack }: PaymobEmbeddedViewProps) {
    const nativeViewRef = useRef<any>(null);
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState<string>('');

    // Secrets (In real app, fetch these securely)
    const publicKey = 'egy_pk_test_jbtqjbZUZpcvIjvMSHrAXVQ2dFVsS0xi';
    const clientSecret = 'egy_csk_test_470ff99341ee584adf6ee587f7d199be';

    // 1. Initial Configure (Settings only)
    useEffect(() => {
        if (nativeViewRef.current) {
            const config = {
                uiCustomization: '{"Payment_Button_Title": "Pay Now"}',
                showAddNewCard: true,
                showSaveCard: true,
                saveCardByDefault: false,
                payFromOutside: false,
            };

            const handle = findNodeHandle(nativeViewRef.current);
            if (handle) {
                // Dispatch CONFIGURE
                dispatchCommand(handle as number, 'configure', [config]);
            }
            setStatus('Ready to Pay');
        }
    }, []);

    // 2. Pay Button Handler (Sets Keys)
    const handlePay = () => {
        if (nativeViewRef.current) {
            setStatus('Initializing Payment...');
            const handle = findNodeHandle(nativeViewRef.current);
            if (handle) {
                const keysConfig = {
                    publicKey,
                    clientSecret
                };
                dispatchCommand(handle as number, 'setPaymentKeys', [keysConfig]);
            }
        }
    };

    const dispatchCommand = (handle: number, commandId: string, args: any[]) => {
        UIManager.dispatchViewManagerCommand(handle, commandId, args);

        // iOS Compatibility check for UIManager lookups if needed
        if (Platform.OS === 'ios') {
            const viewManagerConfig = UIManager.getViewManagerConfig('PaymobCheckoutView');
            if (viewManagerConfig && viewManagerConfig.Commands) {
                const cmd = viewManagerConfig.Commands[commandId];
                if (cmd != null) {
                    UIManager.dispatchViewManagerCommand(handle, cmd, args);
                }
            }
        }
    }


    const handleSuccess = (event: any) => {
        console.log('Paymob Success:', event.nativeEvent);
        setStatus('Success: ' + JSON.stringify(event.nativeEvent));
    };

    const handleFailure = (event: any) => {
        console.log('Paymob Failure:', event.nativeEvent);
        setStatus('Failure: ' + (event.nativeEvent?.error || 'Unknown'));
    };

    const handlePending = (event: any) => {
        console.log('Paymob Pending:', event.nativeEvent);
        setStatus('Pending');
    };

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Checkout</Text>
            </View>

            <Text style={styles.status}>{status}</Text>
            {loading && <ActivityIndicator size="large" color="#0000ff" />}

            <PaymobCheckoutView
                ref={nativeViewRef}
                style={styles.embeddedView}
                onSuccess={handleSuccess}
                onFailure={handleFailure}
                onPending={handlePending}
            />

            <View style={styles.footer}>
                <View style={styles.buttonContainer}>
                    <Button title="Pay / Load Keys" onPress={handlePay} color="#6200EE" />
                </View>
                <View style={{ height: 10 }} />
                <View style={styles.buttonContainer}>
                    <Button title="Back" onPress={onBack} color="#333" />
                </View>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5',
    },
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center', // Center title
        padding: 16,
        backgroundColor: '#fff',
        elevation: 2,
    },
    headerTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        // marginLeft: 16, // Removed margin since it's centered
    },
    status: {
        textAlign: 'center',
        margin: 10,
        color: 'gray'
    },
    embeddedView: {
        height: '50%',
        width: '100%',
        backgroundColor: 'white' // Ensure visible
    },
    footer: {
        padding: 20,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#f5f5f5',
    },
    buttonContainer: {
        width: '50%',
    }
});
