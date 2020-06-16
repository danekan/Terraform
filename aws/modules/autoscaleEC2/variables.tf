variable "web_image_id" {
    type    = string
    #default = "ami-07e0385781d387d02"
}
variable "web_instance_type" {
    type    = string
}
variable "web_desired_capacity" {
    type    = number
}
variable "web_max_size" {
    type    = number
}
variable "web_min_size" {
    type    = number
}
variable "environment" {
    type    = string
}
variable "appname" {
    type    = string
}
variable "subnets" {
    type = list(string)
}
variable "security_groups" {
    type = list(string)
}