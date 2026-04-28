return {
  {
    "BMilliet/git_status.nvim",
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    cmd = {
      "Blame",
      "Conflict",
      "Status",
      "GitStatusRefresh",
      "GitStatusToggle",
    },
    main = "git_status",
    opts = {},
  },
}
