return {
    'intellij_light',
    dir = '~/Development/git/intellij_light',
    config = function()
        require('intellij_light').setup()
        require('intellij_light').load()
    end,
}
