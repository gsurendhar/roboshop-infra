resource "aws_key_pair" "openvpn" {
    key_name   = "openvpn"
    # public_key = file("C:\\Users\\mahes\\OneDrive\\Pictures\\DevOps\\suri.pub")               # off
    public_key = file("C:\\Users\\gonel\\OneDrive\\Desktop\\DevOps\\daws-84s\\suri-n.pub")    # my
}

resource "aws_instance" "vpn" {
    ami                     = local.ami_id
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [local.vpn_sg_id]
    subnet_id               = local.public_subnet_id
    key_name                = aws_key_pair.openvpn.key_name
    user_data               = file("openvpn.sh")
    tags    = merge(
        local.common_tags,
        {
            Name = "${local.Name}-vpn"
        }
    )
}