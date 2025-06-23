return {
  'robitx/gp.nvim',
  config = function()
    local conf = {
      -- Multiple providers
      providers = {
        copilot = {
          endpoint = 'https://api.githubcopilot.com/chat/completions',
          secret = {
            'bash',
            '-c',
            "cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
          },
        },
        ollama = {
          endpoint = 'http://localhost:11434/v1/chat/completions',
          -- Alternative endpoints to try if above doesn't work:
          -- endpoint = "http://127.0.0.1:11434/v1/chat/completions",
          -- endpoint = "http://localhost:11434/api/chat",
        },
      },

      -- Multiple agents for different providers and use cases
      agents = {
        -- Copilot agents
        {
          provider = 'copilot',
          name = 'ChatCopilot',
          chat = true,
          command = false,
          model = { model = 'gpt-4', temperature = 1.1, top_p = 1 },
          system_prompt = require('gp.defaults').chat_system_prompt,
        },
        {
          provider = 'copilot',
          name = 'CodeCopilot',
          chat = false,
          command = true,
          model = { model = 'gpt-4', temperature = 0.8, top_p = 1 },
          system_prompt = 'You are an AI working as a code editor.\n\n'
            .. 'Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n'
            .. 'START AND END YOUR ANSWER WITH:\n\n```',
        },
        {
          provider = 'copilot',
          name = 'ChatCopilot-4o',
          chat = true,
          command = false,
          model = { model = 'gpt-4o', temperature = 1.1, top_p = 1 },
          system_prompt = require('gp.defaults').chat_system_prompt,
        },

        -- Ollama agents (updated with your actual models)
        {
          provider = 'ollama',
          name = 'ChatLlama',
          chat = true,
          command = false,
          model = { model = 'llama3.2:latest', temperature = 1.1, top_p = 1 },
          system_prompt = require('gp.defaults').chat_system_prompt,
        },
        {
          provider = 'ollama',
          name = 'CodeDeepSeek',
          chat = false,
          command = true,
          model = { model = 'deepseek-coder:latest', temperature = 0.8, top_p = 1 },
          system_prompt = 'You are an AI working as a code editor.\n\n'
            .. 'Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n'
            .. 'START AND END YOUR ANSWER WITH:\n\n```',
        },
        {
          provider = 'ollama',
          name = 'ChatDeepSeek',
          chat = true,
          command = false,
          model = { model = 'deepseek-coder:latest', temperature = 0.9, top_p = 1 },
          system_prompt = 'You are an expert programmer and helpful assistant.',
        },
        {
          provider = 'ollama',
          name = 'ChatCodeLlama',
          chat = true,
          command = false,
          model = { model = 'codellama:7b-instruct', temperature = 0.9, top_p = 1 },
          system_prompt = 'You are an expert programmer and helpful assistant.',
        },
      },

      -- Default agents (you can change these anytime)
      default_chat_agent = 'ChatCopilot',
      default_command_agent = 'CodeCopilot',

      -- Chat directory
      chat_dir = vim.fn.stdpath('data'):gsub('/$', '') .. '/gp/chats',
    }
    require('gp').setup(conf)

    -- Key mappings
    local function keymapOptions(desc)
      return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = 'GPT prompt ' .. desc,
      }
    end

    require('which-key').add {
      -- VISUAL mode mappings
      -- s, x, v modes are handled the same way by which_key
      {
        mode = { 'v' },
        nowait = true,
        remap = false,
        { '<C-g><C-t>', ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = 'ChatNew tabnew' },
        { '<C-g><C-v>', ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = 'ChatNew vsplit' },
        { '<C-g><C-x>', ":<C-u>'<,'>GpChatNew split<cr>", desc = 'ChatNew split' },
        { '<C-g>a', ":<C-u>'<,'>GpAppend<cr>", desc = 'Visual Append (after)' },
        { '<C-g>b', ":<C-u>'<,'>GpPrepend<cr>", desc = 'Visual Prepend (before)' },
        { '<C-g>c', ":<C-u>'<,'>GpChatNew<cr>", desc = 'Visual Chat New' },
        { '<C-g>g', group = 'generate into new ..' },
        { '<C-g>ge', ":<C-u>'<,'>GpEnew<cr>", desc = 'Visual GpEnew' },
        { '<C-g>gn', ":<C-u>'<,'>GpNew<cr>", desc = 'Visual GpNew' },
        { '<C-g>gp', ":<C-u>'<,'>GpPopup<cr>", desc = 'Visual Popup' },
        { '<C-g>gt', ":<C-u>'<,'>GpTabnew<cr>", desc = 'Visual GpTabnew' },
        { '<C-g>gv', ":<C-u>'<,'>GpVnew<cr>", desc = 'Visual GpVnew' },
        { '<C-g>i', ":<C-u>'<,'>GpImplement<cr>", desc = 'Implement selection' },
        { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
        { '<C-g>p', ":<C-u>'<,'>GpChatPaste<cr>", desc = 'Visual Chat Paste' },
        { '<C-g>r', ":<C-u>'<,'>GpRewrite<cr>", desc = 'Visual Rewrite' },
        { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
        { '<C-g>t', ":<C-u>'<,'>GpChatToggle<cr>", desc = 'Visual Toggle Chat' },
        { '<C-g>w', group = 'Whisper' },
        { '<C-g>wa', ":<C-u>'<,'>GpWhisperAppend<cr>", desc = 'Whisper Append' },
        { '<C-g>wb', ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = 'Whisper Prepend' },
        { '<C-g>we', ":<C-u>'<,'>GpWhisperEnew<cr>", desc = 'Whisper Enew' },
        { '<C-g>wn', ":<C-u>'<,'>GpWhisperNew<cr>", desc = 'Whisper New' },
        { '<C-g>wp', ":<C-u>'<,'>GpWhisperPopup<cr>", desc = 'Whisper Popup' },
        { '<C-g>wr', ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = 'Whisper Rewrite' },
        { '<C-g>wt', ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = 'Whisper Tabnew' },
        { '<C-g>wv', ":<C-u>'<,'>GpWhisperVnew<cr>", desc = 'Whisper Vnew' },
        { '<C-g>ww', ":<C-u>'<,'>GpWhisper<cr>", desc = 'Whisper' },
        { '<C-g>x', ":<C-u>'<,'>GpContext<cr>", desc = 'Visual GpContext' },
      },

      -- NORMAL mode mappings
      {
        mode = { 'n' },
        nowait = true,
        remap = false,
        { '<C-g><C-t>', '<cmd>GpChatNew tabnew<cr>', desc = 'New Chat tabnew' },
        { '<C-g><C-v>', '<cmd>GpChatNew vsplit<cr>', desc = 'New Chat vsplit' },
        { '<C-g><C-x>', '<cmd>GpChatNew split<cr>', desc = 'New Chat split' },
        { '<C-g>a', '<cmd>GpAppend<cr>', desc = 'Append (after)' },
        { '<C-g>b', '<cmd>GpPrepend<cr>', desc = 'Prepend (before)' },
        { '<C-g>c', '<cmd>GpChatNew<cr>', desc = 'New Chat' },
        { '<C-g>f', '<cmd>GpChatFinder<cr>', desc = 'Chat Finder' },
        { '<C-g>g', group = 'generate into new ..' },
        { '<C-g>ge', '<cmd>GpEnew<cr>', desc = 'GpEnew' },
        { '<C-g>gn', '<cmd>GpNew<cr>', desc = 'GpNew' },
        { '<C-g>gp', '<cmd>GpPopup<cr>', desc = 'Popup' },
        { '<C-g>gt', '<cmd>GpTabnew<cr>', desc = 'GpTabnew' },
        { '<C-g>gv', '<cmd>GpVnew<cr>', desc = 'GpVnew' },
        { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
        { '<C-g>r', '<cmd>GpRewrite<cr>', desc = 'Inline Rewrite' },
        { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
        { '<C-g>t', '<cmd>GpChatToggle<cr>', desc = 'Toggle Chat' },
        { '<C-g>w', group = 'Whisper' },
        { '<C-g>wa', '<cmd>GpWhisperAppend<cr>', desc = 'Whisper Append (after)' },
        { '<C-g>wb', '<cmd>GpWhisperPrepend<cr>', desc = 'Whisper Prepend (before)' },
        { '<C-g>we', '<cmd>GpWhisperEnew<cr>', desc = 'Whisper Enew' },
        { '<C-g>wn', '<cmd>GpWhisperNew<cr>', desc = 'Whisper New' },
        { '<C-g>wp', '<cmd>GpWhisperPopup<cr>', desc = 'Whisper Popup' },
        { '<C-g>wr', '<cmd>GpWhisperRewrite<cr>', desc = 'Whisper Inline Rewrite' },
        { '<C-g>wt', '<cmd>GpWhisperTabnew<cr>', desc = 'Whisper Tabnew' },
        { '<C-g>wv', '<cmd>GpWhisperVnew<cr>', desc = 'Whisper Vnew' },
        { '<C-g>ww', '<cmd>GpWhisper<cr>', desc = 'Whisper' },
        { '<C-g>x', '<cmd>GpContext<cr>', desc = 'Toggle GpContext' },
      },

      -- INSERT mode mappings
      {
        mode = { 'i' },
        nowait = true,
        remap = false,
        { '<C-g><C-t>', '<cmd>GpChatNew tabnew<cr>', desc = 'New Chat tabnew' },
        { '<C-g><C-v>', '<cmd>GpChatNew vsplit<cr>', desc = 'New Chat vsplit' },
        { '<C-g><C-x>', '<cmd>GpChatNew split<cr>', desc = 'New Chat split' },
        { '<C-g>a', '<cmd>GpAppend<cr>', desc = 'Append (after)' },
        { '<C-g>b', '<cmd>GpPrepend<cr>', desc = 'Prepend (before)' },
        { '<C-g>c', '<cmd>GpChatNew<cr>', desc = 'New Chat' },
        { '<C-g>f', '<cmd>GpChatFinder<cr>', desc = 'Chat Finder' },
        { '<C-g>g', group = 'generate into new ..' },
        { '<C-g>ge', '<cmd>GpEnew<cr>', desc = 'GpEnew' },
        { '<C-g>gn', '<cmd>GpNew<cr>', desc = 'GpNew' },
        { '<C-g>gp', '<cmd>GpPopup<cr>', desc = 'Popup' },
        { '<C-g>gt', '<cmd>GpTabnew<cr>', desc = 'GpTabnew' },
        { '<C-g>gv', '<cmd>GpVnew<cr>', desc = 'GpVnew' },
        { '<C-g>n', '<cmd>GpNextAgent<cr>', desc = 'Next Agent' },
        { '<C-g>r', '<cmd>GpRewrite<cr>', desc = 'Inline Rewrite' },
        { '<C-g>s', '<cmd>GpStop<cr>', desc = 'GpStop' },
        { '<C-g>t', '<cmd>GpChatToggle<cr>', desc = 'Toggle Chat' },
        { '<C-g>w', group = 'Whisper' },
        { '<C-g>wa', '<cmd>GpWhisperAppend<cr>', desc = 'Whisper Append (after)' },
        { '<C-g>wb', '<cmd>GpWhisperPrepend<cr>', desc = 'Whisper Prepend (before)' },
        { '<C-g>we', '<cmd>GpWhisperEnew<cr>', desc = 'Whisper Enew' },
        { '<C-g>wn', '<cmd>GpWhisperNew<cr>', desc = 'Whisper New' },
        { '<C-g>wp', '<cmd>GpWhisperPopup<cr>', desc = 'Whisper Popup' },
        { '<C-g>wr', '<cmd>GpWhisperRewrite<cr>', desc = 'Whisper Inline Rewrite' },
        { '<C-g>wt', '<cmd>GpWhisperTabnew<cr>', desc = 'Whisper Tabnew' },
        { '<C-g>wv', '<cmd>GpWhisperVnew<cr>', desc = 'Whisper Vnew' },
        { '<C-g>ww', '<cmd>GpWhisper<cr>', desc = 'Whisper' },
        { '<C-g>x', '<cmd>GpContext<cr>', desc = 'Toggle GpContext' },
      },
    }
  end,
}

-- Setup Instructions:
--
-- For Ollama models:
-- 1. Install Ollama: curl -fsSL https://ollama.com/install.sh | sh
-- 2. Start service: ollama serve
-- 3. Pull models:
--    ollama pull llama3.2        # Good general chat (4GB)
--    ollama pull deepseek-coder  # Excellent for coding (1.3GB)
--    ollama pull codestral       # Great coding model (4GB)
--    ollama pull qwen2.5-coder   # Alternative coding model (1.5GB)
--
-- Model size reference:
-- - llama3.2:1b    # Fastest, smallest (1.3GB)
-- - llama3.2:3b    # Good balance (2GB)
-- - llama3.2       # Standard (4.7GB)
-- - deepseek-coder # Best for code (1.3GB)
