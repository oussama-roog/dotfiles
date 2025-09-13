local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

-- Helper functions
local snips = {}

function snips.make_return_nodes(args)
	local err_var = args[1][1]
	return sn(nil, {
		c(1, {
			t(""),
			sn(nil, { t(", "), i(1, "nil") }),
			sn(nil, { t(", "), i(1, err_var) }),
		}),
	})
end

function snips.make_default_return_nodes(args)
	local err_var = args[1][1]
	return sn(nil, {
		c(1, {
			t(""),
			sn(nil, { t(", "), i(1, "nil") }),
			sn(nil, { t(", "), i(1, err_var) }),
		}),
	})
end

function snips.create_t_run(args)
	return sn(nil, {
		t('t.Run("'),
		i(1, "test_name"),
		t('", func(t *testing.T) {'),
		t({ "", "\t" }),
		i(2),
		t({ "", "})" }),
	})
end

function snips.mirror_t_run_funcs(args)
	local t_runs = {}
	for _, v in ipairs(args[1]) do
		table.insert(
			t_runs,
			sn(nil, {
				t({ "", "" }),
				t("func "),
				i(1, "Test" .. v[1][1]),
				t("(t *testing.T) {"),
				t({ "", "\t" }),
				i(2),
				t({ "", "}" }),
			})
		)
	end
	return sn(nil, t_runs)
end

-- Conditions
local in_fn = conds_expand.line_begin
	* conds.make_condition(function()
		return vim.fn.search("\\<func\\>", "bWn") > 0
	end)

local not_in_fn = -in_fn

local in_test_fn = conds_expand.line_begin
	* conds.make_condition(function()
		return vim.fn.search("\\<func Test\\|func Benchmark\\|func Example\\>", "bWn") > 0
	end)

local in_test_file = conds.make_condition(function()
	return vim.fn.expand("%:t"):match("_test%.go$") ~= nil
end)

local snippets = {
	-- Main
	s(
		{ trig = "main", name = "Main", dscr = "Create a main function" },
		fmta("func main() {\n\t<>\n}", i(0)),
		not_in_fn
	),
	s("ret", {
		t("return "),
		i(1),
		t(""),
		d(2, snips.make_default_return_nodes, { 1 }),
	}, in_fn),

	-- If call error
	s(
		{ trig = "ifc", name = "if call", dscr = "Call a function and check the error" },
		fmt(
			[[
        {val}, {err1} := {func}({args})
        if {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]],
			{
				val = i(1, "val"),
				err1 = i(2, "err"),
				func = i(3, "func"),
				args = i(4),
				err2 = rep(2),
				err3 = d(5, snips.make_return_nodes, { 2 }),
				finally = i(0),
			}
		),
		in_fn
	),

	-- if err:=call(); err != nil { return err }
	s(
		{ trig = "ifce", name = "if call err inline", dscr = "Call a function and check the error inline" },
		fmt(
			[[
        if {err1} := {func}({args}); {err2} != nil {{
          return {err3}
        }}
        {finally}
      ]],
			{
				err1 = i(1, "err"),
				func = i(2, "func"),
				args = i(3, "args"),
				err2 = rep(1),
				err3 = d(4, snips.make_return_nodes, { 1 }),
				finally = i(0),
			}
		),
		in_fn
	),

	-- Function
	s(
		{ trig = "fn", name = "Function", dscr = "Create a function or a method" },
		fmt(
			[[
        // {name1} {desc}
        func {rec}{name2}({args}) {ret} {{
          {finally}
        }}
      ]],
			{
				name1 = rep(2),
				desc = i(5, "description"),
				rec = c(1, {
					t(""),
					sn(
						nil,
						fmt("({} {}) ", {
							i(1, "r"),
							i(2, "receiver"),
						})
					),
				}),
				name2 = i(2, "Name"),
				args = i(3),
				ret = c(4, {
					i(1, "error"),
					sn(
						nil,
						fmt("({}, {}) ", {
							i(1, "ret"),
							i(2, "error"),
						})
					),
				}),
				finally = i(0),
			}
		),
		not_in_fn
	),

	-- If error
	s(
		{ trig = "ife", name = "If error, choose me!", dscr = "If error, return wrapped with dynamic node" },
		fmt("if {} != nil {{\n\treturn {}\n}}\n{}", {
			i(1, "err"),
			d(2, snips.make_return_nodes, { 1 }, { user_args = { { "a1", "a2" } } }),
			i(0),
		}),
		in_fn
	),

	-- errors.Wrap
	s(
		{ trig = "erw", dscr = "errors.Wrap" },
		fmt([[errors.Wrap({}, "{}")]], {
			i(1, "err"),
			i(2, "failed to"),
		})
	),

	-- errors.Wrapf
	s(
		{ trig = "erwf", dscr = "errors.Wrapf" },
		fmt([[errors.Wrapf({}, "{}", {})]], {
			i(1, "err"),
			i(2, "failed %v"),
			i(3, "args"),
		})
	),

	-- for select
	s(
		{ trig = "fsel", dscr = "for select" },
		fmt(
			[[
for {{
	  select {{
        case {} <- {}:
			      {}
        default:
            {}
	  }}
}}
]],
			{
				c(1, { i(1, "ch"), i(2, "ch := ") }),
				i(2, "ch"),
				i(3, "break"),
				i(0, ""),
			}
		)
	),

	s(
		{ trig = "for([%w_]+)", regTrig = true, hidden = true },
		fmt(
			[[
for  {} := 0; {} < {}; {}++ {{
  {}
}}
{}
    ]],
			{
				d(1, function(_, snip)
					return sn(1, i(1, snip.captures[1]))
				end),
				rep(1),
				c(2, { i(1, "num"), sn(1, { t("len("), i(1, "arr"), t(")") }) }),
				rep(1),
				i(3, "// TODO:"),
				i(4),
			}
		),
		in_fn
	),
	-- type switch
	s(
		{ trig = "tysw", dscr = "type switch" },
		fmt(
			[[
switch {} := {}.(type) {{
    case {}:
        {}
    default:
        {}
}}
]],
			{
				i(1, "v"),
				i(2, "i"),
				i(3, "int"),
				i(4, 'fmt.Println("int")'),
				i(0, ""),
			}
		)
	),
	-- fmt.Sprintf
	s(
		{ trig = "spn", dscr = "fmt.Sprintf" },
		fmt([[fmt.Sprintf("{}%{}", {})]], {
			i(1, "msg "),
			i(2, "+v"),
			i(2, "arg"),
		})
	),

	-- build tags
	s(
		{ trig = "//tag", dscr = "// +build tags" },
		fmt([[// +build:{}{}]], {
			i(1, "integration"),
			i(2, ",unit"),
		})
	),

	-- Nolint
	s(
		{ trig = "nolt", dscr = "ignore linter" },
		fmt([[// nolint:{}{}]], {
			i(1, "funlen"),
			i(2, ",cyclop"),
		})
	),

	-- defer recover
	s(
		{ trig = "dfr", dscr = "defer recover" },
		fmt(
			[[
        defer func() {{
            if err := recover(); err != nil {{
       	        {}
            }}
        }}()]],
			{
				i(1, ""),
			}
		)
	),

	-- Allocate Slices and Maps
	s(
		{ trig = "mk", name = "Make", dscr = "Allocate map or slice" },
		fmt("{} {}= make({})\n{}", {
			i(1, "name"),
			i(2),
			c(3, {
				fmt("[]{}, {}", { r(1, "type"), i(2, "len") }),
				fmt("[]{}, 0, {}", { r(1, "type"), i(2, "len") }),
				fmt("map[{}]{}, {}", { r(1, "type"), i(2, "values"), i(3, "len") }),
			}, {
				stored = { -- FIXME: the default value is not set.
					type = i(1, "type"),
				},
			}),
			i(0),
		}),
		in_fn
	),

	-- Test Cases
	s(
		{ trig = "tcs", dscr = "create test cases for testing" },
		fmta(
			[[
        tcs := map[string]struct {
        	<>
        } {
        	// Test cases here
        }
        for name, tc := range tcs {
        	tc := tc
        	t.Run(name, func(t *testing.T) {
        		<>
        	})
        }
      ]],
			{ i(1), i(2) }
		),
		in_test_fn
	),

	-- gRPC Error
	s(
		{ trig = "gerr", dscr = "Return an instrumented gRPC error" },
		fmt('internal.GrpcError({},\n\tcodes.{}, "{}", "{}", {})', {
			i(1, "err"),
			i(2, "Internal"),
			i(3, "Description"),
			i(4, "Field"),
			i(5, "fields"),
		}),
		in_fn
	),

	s(
		{ trig = "hf", name = "http.HandlerFunc", dscr = "http handler" },
		fmt(
			[[
    func {}(w http.ResponseWriter, r *http.Request) {{
        {}
    }}
]],
			{
				i(1, "handler"),
				i(2, [[fmt.Fprintf(w, "hello world")"]]),
			}
		)
	),

	-- deep equal
	s(
		{ trig = "deq", name = "reflect Deep equal", dscr = "Compare with deep equal and print error" },
		fmt(
			[[
if !reflect.DeepEqual({}, {}) {{
	_, file, line, _ := runtime.Caller(0)
    fmt.Printf("%s:%d:\n\n\texp: %#v\n\n\tgot: %#v\n\n", filepath.Base(file), line, {}, {})
    t.FailNow()
}}]],
			{
				i(1, "expected"),
				i(2, "got"),
				rep(1),
				rep(2),
			}
		),
		in_test_fn
	),
	-- Create Mocks
	s(
		{ trig = "mock", name = "Mocks create", dscr = "Create a mock with NewFactory" },
		fmt("{} := &mocks.{}({})", {
			i(1, "m"),
			i(2, "NewFactory"),
			i(3, "t"),
		}),
		in_test_fn
	),

	-- Http request with defer close
	s(
		{ trig = "hreq", name = "http request with defer close", dscr = "create a http request with defer body close" },
		fmt(
			[[
  {}, {} := http.{}("http://{}:" + {} + "/{}")
	if {} != nil {{
		log.Fatalln({})
	}}
	_ = {}.Body.Close()

    ]],
			{
				i(1, "resp"),
				i(2, "err"),
				c(3, { i(1, "Get"), i(2, "Post"), i(3, "Patch") }),
				i(4, "localhost"),
				i(5, [["8080"]]),
				i(6, "path"),
				rep(2),
				rep(2),
				rep(1),
			}
		),
		in_test_fn
	),

	-- Go CMP
	s(
		{ trig = "gocmp", dscr = "Create an if block comparing with cmp.Diff" },
		fmt(
			[[
        if diff := cmp.Diff({}, {}); diff != "" {{
        	t.Errorf("(-want +got):\\n%s", diff)
        }}
      ]],
			{
				i(1, "want"),
				i(2, "got"),
			}
		),
		in_test_fn
	),

	-- Require NoError
	s(
		{ trig = "noerr", name = "Require No Error", dscr = "Add a require.NoError call" },
		c(1, {
			sn(nil, fmt("require.NoError(t, {})", { i(1, "err") })),
			sn(nil, fmt('require.NoError(t, {}, "{}")', { i(1, "err"), i(2) })),
			sn(nil, fmt('require.NoErrorf(t, {}, "{}", {})', { i(1, "err"), i(2), i(3) })),
		}),
		in_test_fn
	),

	-- Assert equal
	s(
		{ trig = "aeq", name = "Assert Equal", dscr = "Add assert.Equal" },
		c(1, {
			sn(nil, fmt("assert.Equal(t, {}, {})", { i(1, "got"), i(2, "want") })),
			sn(
				nil,
				fmt(
					'assert.Equalf(t, {}, {}, "{}", {})',
					{ i(1, "got"), i(2, "want"), i(3, "got %v not equal to want"), i(4, "got") }
				)
			),
		}),
		in_test_fn
	),

	-- Subtests
	s(
		{ trig = "test", name = "Test & Subtest", dscr = "Create subtests and their function stubs" },
		fmta("func <>(t *testing.T) {\n<>\n}\n\n <>", {
			i(1),
			d(2, snips.create_t_run, { 1 }),
			d(3, snips.mirror_t_run_funcs, { 2 }),
		}),
		in_test_file
	),

	-- bench test
	s(
		{ trig = "bench", name = "bench test cases ", dscr = "Create benchmark test" },
		fmt(
			[[
	    func Benchmark{}(b *testing.B) {{
	        for i := 0; i < b.N; i++ {{
	     	    {}({})
	        }}
	    }}]],
			{
				i(1, "MethodName"),
				rep(1),
				i(2, "args"),
			}
		),
		in_test_file
	),

	-- Stringer
	s(
		{ trig = "strigner", name = "Stringer", dscr = "Create a stringer go:generate" },
		fmt("//go:generate stringer -type={} -output={}_string.go", {
			i(1, "Type"),
			p(vim.fn.expand, "%:t:r"),
		})
	),
}

ls.add_snippets("go", snippets)

