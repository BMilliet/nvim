return {
  {
    "BMilliet/git_status.nvim",
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    cmd = {
      "Blame",
      "GitStatusRefresh",
      "GitStatusToggle",
    },
    main = "git_status",
    opts = {},
  },
}
