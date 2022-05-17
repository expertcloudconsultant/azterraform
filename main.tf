#initial setup of terraform

variable "firstvar" {
    type = string
<<<<<<< HEAD
    default = "hello nana esther momo"
=======
    default = "east-us"
>>>>>>> 82ee969da3c97dc5c23cbbaac4a80e7a7bf44bc3

}

variable "mymap" {
    type = map(string)
    default = {
      mykey = "this is my value"
    }
}
