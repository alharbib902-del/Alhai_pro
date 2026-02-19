import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/pin_service.dart';

/// شاشة موافقة المشرف بـ PIN
class ManagerApprovalScreen extends StatefulWidget {
  const ManagerApprovalScreen({super.key});

  @override
  State<ManagerApprovalScreen> createState() => _ManagerApprovalScreenState();
}

class _ManagerApprovalScreenState extends State<ManagerApprovalScreen> {
  String _pin = '';
  bool _isLoading = false;
  String? _error;
  bool _needsSetup = false;
  bool _isSettingUp = false;
  String _setupPin = '';
  String _confirmPin = '';

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  Future<void> _checkPinSetup() async {
    final hasPin = await PinService.isEnabled();
    if (!hasPin && mounted) {
      setState(() => _needsSetup = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsSetup) {
      return _buildSetupScreen();
    }
    
    return _buildVerifyScreen();
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد رمز المشرف'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline, size: 40, color: Colors.green.shade700),
              ),
              const SizedBox(height: 24),

              Text(
                _isSettingUp ? 'تأكيد الرمز' : 'إنشاء رمز جديد',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isSettingUp 
                    ? 'أعد إدخال الرمز للتأكيد'
                    : 'أدخل رمز PIN من 4 أرقام',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // PIN display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final currentPin = _isSettingUp ? _confirmPin : _setupPin;
                  return Container(
                    width: 50,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: index < currentPin.length ? Colors.green : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _error != null 
                            ? Colors.red 
                            : (index < currentPin.length ? Colors.green : Colors.grey.shade300),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: index < currentPin.length
                          ? const Icon(Icons.circle, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),

              // Keypad
              _buildKeypad(isSetup: true),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موافقة المشرف'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 24),

              const Text(
                'أدخل رمز المشرف',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'هذه العملية تتطلب موافقة المشرف',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // PIN display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: index < _pin.length ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _error != null ? Colors.red : (index < _pin.length ? Colors.blue : Colors.grey.shade300),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: index < _pin.length
                          ? const Icon(Icons.circle, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),

              // Keypad
              _buildKeypad(isSetup: false),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad({required bool isSetup}) {
    return SizedBox(
      width: 280,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (index == 9) {
            // Clear button
            return _KeypadButton(
              label: 'C',
              onTap: () => setState(() {
                if (isSetup) {
                  if (_isSettingUp) {
                    _confirmPin = '';
                  } else {
                    _setupPin = '';
                  }
                } else {
                  _pin = '';
                }
                _error = null;
              }),
              color: Colors.red.shade100,
              textColor: Colors.red,
            );
          } else if (index == 10) {
            // 0
            return _KeypadButton(
              label: '0',
              onTap: () => _addDigit('0', isSetup: isSetup),
            );
          } else if (index == 11) {
            // Backspace
            return _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () {
                setState(() {
                  if (isSetup) {
                    if (_isSettingUp && _confirmPin.isNotEmpty) {
                      _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
                    } else if (!_isSettingUp && _setupPin.isNotEmpty) {
                      _setupPin = _setupPin.substring(0, _setupPin.length - 1);
                    }
                  } else if (_pin.isNotEmpty) {
                    _pin = _pin.substring(0, _pin.length - 1);
                  }
                  _error = null;
                });
              },
              color: Colors.grey.shade200,
            );
          } else {
            // 1-9
            final digit = (index + 1).toString();
            return _KeypadButton(
              label: digit,
              onTap: () => _addDigit(digit, isSetup: isSetup),
            );
          }
        },
      ),
    );
  }

  void _addDigit(String digit, {required bool isSetup}) {
    if (_isLoading) return;

    if (isSetup) {
      if (_isSettingUp) {
        if (_confirmPin.length >= 4) return;
        setState(() {
          _confirmPin += digit;
          _error = null;
        });
        if (_confirmPin.length == 4) {
          _confirmSetup();
        }
      } else {
        if (_setupPin.length >= 4) return;
        setState(() {
          _setupPin += digit;
          _error = null;
        });
        if (_setupPin.length == 4) {
          setState(() => _isSettingUp = true);
        }
      }
    } else {
      if (_pin.length >= 4) return;
      setState(() {
        _pin += digit;
        _error = null;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  Future<void> _confirmSetup() async {
    if (_setupPin != _confirmPin) {
      setState(() {
        _error = 'الرمزان غير متطابقين';
        _confirmPin = '';
      });
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await PinService.createPin(_setupPin);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء رمز المشرف بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _needsSetup = false;
        _isSettingUp = false;
        _setupPin = '';
        _confirmPin = '';
      });
    } else {
      setState(() {
        _error = result.error;
        _confirmPin = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    
    final result = await PinService.verifyPin(_pin);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت الموافقة'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true); // Return success
    } else {
      setState(() {
        _pin = '';
        
        if (result.errorType == PinError.lockedOut && result.lockedUntil != null) {
          final remaining = result.lockedUntil!.difference(DateTime.now());
          _error = 'تم قفل الحساب. انتظر ${remaining.inMinutes} دقيقة';
        } else if (result.remainingAttempts != null) {
          _error = 'رمز خاطئ. المحاولات المتبقية: ${result.remainingAttempts}';
        } else {
          _error = result.error;
        }
      });
    }
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor ?? Colors.grey.shade700)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.grey.shade800,
                  ),
                ),
        ),
      ),
    );
  }
}
