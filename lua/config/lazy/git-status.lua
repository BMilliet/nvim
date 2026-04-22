return {
  {
    "BMilliet/git_status.nvim",
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    cmd = {
      "Blame",
      "Status",
      "GitStatusRefresh",
      "GitStatusToggle",
    },
    main = "git_status",
    opts = {},
  },
}
