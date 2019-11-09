data "aws_region" "current" {}

locals {
  bucketDocs    = format("s3-ma-docs-%s","${var.tags.Environment}")
  bucketAdmin   = format("admin.devops-test-miaguila.com")
}


resource "aws_s3_bucket" "s3_ma_docs" {
  bucket        = "${local.bucketDocs}"
  region        = "${data.aws_region.current.name}"
  request_payer = "BucketOwner"
  acl           = "private"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.bucketDocs}/*"
        }
    ]
}
EOF

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }


  versioning {}

  website {
    error_document = "index.html"
    index_document = "index.html"
  }

}

resource "aws_s3_bucket" "s3_ma_admin" {
  bucket        = "${local.bucketAdmin}"
  region        = "${data.aws_region.current.name}"
  request_payer = "BucketOwner"
  acl           = "private"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.bucketAdmin}/*"
        }
    ]
}
EOF

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }


  versioning {}

  website {
    error_document = "index.html"
    index_document = "index.html"
  }

}

/* index.html content
<html>
<header><title>Bienvenidos a Mi Águila</title></header>
<body>
Bienvenidos a Mi Águila
</body>
</html>
*/
resource "aws_s3_bucket_object" "s3_ma_admin_object" {
  bucket = "${local.bucketAdmin}"
  key    = "index.html"
  content_base64 = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkJpZW52ZW5pZG9zIGEgTWkgw4FndWlsYTwvdGl0bGU+PC9oZWFkZXI+Cjxib2R5PgpCaWVudmVuaWRvcyBhIE1pIMOBZ3VpbGEKPC9ib2R5Pgo8L2h0bWw+"
  content_type = "text/html"
}
