return require("telescope").register_extension {
  exports = {
    edit_list = require("edit-list").CallEditList
  }
}
