#initial setup of terraform

variable "firstvar" {
    type = string
    default = "hello nana esther momo"

}

variable "mymap" {
    type = map(string)
    default = {
      mykey = "this is my value"
    }
}
