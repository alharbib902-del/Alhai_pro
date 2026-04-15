# Distributor Documents - Backend Requirements

> **Status**: Not deployed. Apply these migrations before enabling the feature.

## Table: `distributor_documents`

```sql
CREATE TABLE distributor_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES organizations(id),
  document_type text NOT NULL CHECK (document_type IN (
    'commercial_registration',
    'vat_certificate',
    'ceo_national_id'
  )),
  file_url text NOT NULL,       -- storage path (not public URL)
  file_name text NOT NULL,
  file_size bigint NOT NULL,
  mime_type text NOT NULL,

  -- Verification
  status text NOT NULL DEFAULT 'under_review' CHECK (status IN (
    'under_review',
    'approved',
    'rejected'
  )),
  reviewed_by uuid REFERENCES profiles(id),
  reviewed_at timestamptz,
  rejection_reason text,

  -- Audit
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz,

  -- Metadata
  expiry_date date,  -- CR/VAT certificates expire

  -- Only one active document per type per org
  CONSTRAINT unique_active_document UNIQUE (org_id, document_type)
    -- Note: Postgres doesn't support WHERE on UNIQUE directly.
    -- Use a partial unique index instead (see below).
);

-- Partial unique index: only one under_review or approved doc per type per org
CREATE UNIQUE INDEX idx_unique_active_document
  ON distributor_documents (org_id, document_type)
  WHERE status IN ('under_review', 'approved');

-- Performance index
CREATE INDEX idx_distributor_documents_org
  ON distributor_documents (org_id, uploaded_at DESC);
```

## RLS Policies

```sql
ALTER TABLE distributor_documents ENABLE ROW LEVEL SECURITY;

-- Distributors see only their own org's docs
CREATE POLICY distributor_documents_own_select ON distributor_documents
  FOR SELECT TO authenticated
  USING (
    org_id IN (
      SELECT org_id FROM profiles WHERE id = auth.uid()
    )
  );

-- Distributors can INSERT docs for their own org
CREATE POLICY distributor_documents_own_insert ON distributor_documents
  FOR INSERT TO authenticated
  WITH CHECK (
    org_id IN (
      SELECT org_id FROM profiles WHERE id = auth.uid()
    )
  );

-- Distributors can DELETE only non-approved docs
CREATE POLICY distributor_documents_own_delete ON distributor_documents
  FOR DELETE TO authenticated
  USING (
    org_id IN (
      SELECT org_id FROM profiles WHERE id = auth.uid()
    )
    AND status != 'approved'
  );

-- Admin can UPDATE status
CREATE POLICY distributor_documents_admin_update ON distributor_documents
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  );
```

## Storage Bucket: `distributor-documents`

| Setting          | Value                                      |
|------------------|--------------------------------------------|
| Bucket name      | `distributor-documents`                    |
| Public           | **NO**                                     |
| File size limit  | 10 MB                                      |
| Allowed MIME     | `application/pdf`, `image/jpeg`, `image/png` |

### Path format

```
{org_id}/{document_type}/{timestamp}_{filename}
```

Example: `abc-123/commercial_registration/1713200000000_cr.pdf`

### Storage Policies

```sql
-- Distributors upload to their own org folder
CREATE POLICY "Distributors upload own documents"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'distributor-documents'
  AND (storage.foldername(name))[1] IN (
    SELECT org_id::text FROM profiles WHERE id = auth.uid()
  )
);

-- Distributors view own org documents
CREATE POLICY "Distributors view own documents"
ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'distributor-documents'
  AND (storage.foldername(name))[1] IN (
    SELECT org_id::text FROM profiles WHERE id = auth.uid()
  )
);

-- Distributors delete own non-approved documents
CREATE POLICY "Distributors delete own documents"
ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'distributor-documents'
  AND (storage.foldername(name))[1] IN (
    SELECT org_id::text FROM profiles WHERE id = auth.uid()
  )
);

-- Admin views all documents
CREATE POLICY "Admin views all documents"
ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'distributor-documents'
  AND EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'super_admin'
  )
);
```

## Signed URL Access

Documents are accessed via signed URLs (1-hour expiry):

```dart
final url = supabase.storage
    .from('distributor-documents')
    .createSignedUrl(storagePath, 3600);
```

## Admin Review Workflow (Future Session)

- Admin dashboard lists documents with `status = 'under_review'`
- Admin can approve or reject with reason
- Admin review UI is NOT part of this implementation
