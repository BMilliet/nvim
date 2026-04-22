return {
  {
    "BMilliet/git_scrollbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    cmd = "GitScrollbarToggle",
    main = "git_scrollbar",
    opts = {},
  },
}
