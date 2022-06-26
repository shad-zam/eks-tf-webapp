{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${acct-number}:oidc-provider/oidc.eks.${region}.amazonaws.com/id/${oidc_token}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.${region}.amazonaws.com/id/${oidc_token}:aud": "sts.amazonaws.com",
                    "oidc.eks.${region}.amazonaws.com/id/${oidc_token}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}