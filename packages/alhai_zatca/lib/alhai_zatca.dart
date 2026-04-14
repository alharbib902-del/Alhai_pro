library alhai_zatca;

// ─── Models ────────────────────────────────────────────────────
export 'src/models/certificate_info.dart';
export 'src/models/invoice_type_code.dart';
export 'src/models/reporting_status.dart';
export 'src/models/zatca_buyer.dart';
export 'src/models/zatca_invoice.dart';
export 'src/models/zatca_invoice_line.dart';
export 'src/models/zatca_response.dart';
export 'src/models/zatca_seller.dart';

// ─── XML Generation ────────────────────────────────────────────
export 'src/xml/ubl_invoice_builder.dart';
export 'src/xml/ubl_namespaces.dart';
export 'src/xml/invoice_line_builder.dart';
export 'src/xml/tax_total_builder.dart';
export 'src/xml/xml_canonicalizer.dart';

// ─── Digital Signing ───────────────────────────────────────────
export 'src/signing/xades_signer.dart';
export 'src/signing/invoice_hasher.dart';
export 'src/signing/certificate_parser.dart';
export 'src/signing/ecdsa_signer.dart';

// ─── Invoice Chaining (PIH) ───────────────────────────────────
export 'src/chaining/invoice_chain_service.dart';
export 'src/chaining/chain_store.dart';

// ─── QR Code ───────────────────────────────────────────────────
export 'src/qr/zatca_tlv_encoder.dart';
export 'src/qr/zatca_qr_service.dart';
export 'src/qr/vat_calculator.dart';

// ─── API Integration ───────────────────────────────────────────
export 'src/api/zatca_api_client.dart';
export 'src/api/zatca_endpoints.dart';
export 'src/api/compliance_api.dart';
export 'src/api/reporting_api.dart';
export 'src/api/clearance_api.dart';

// ─── Certificate Management ────────────────────────────────────
export 'src/certificate/csr_generator.dart';
export 'src/certificate/csid_onboarding_service.dart';
export 'src/certificate/certificate_storage.dart';
export 'src/certificate/certificate_renewal_service.dart';

// ─── Services ──────────────────────────────────────────────────
export 'src/services/zatca_invoice_service.dart';
export 'src/services/zatca_offline_queue.dart';
export 'src/services/zatca_compliance_checker.dart';
export 'src/services/invoice_xml_validator.dart';

// ─── Dependency Injection ──────────────────────────────────────
export 'src/di/zatca_module.dart';

// ─── Providers ─────────────────────────────────────────────────
export 'src/providers/zatca_providers.dart';
