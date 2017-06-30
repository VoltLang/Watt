module test;

import watt.text.sink;
import vdoc = watt.text.vdoc;

struct Section
{
	enum Type
	{
		Start,
		Content,
		End,
		P,
		Link,
		BriefStart,
		BriefContent,
		BriefEnd,
		ParamStart,
		ParamContent,
		ParamEnd,
	}

	type: Type;
	val: string;
}

fn typeToString(type: Section.Type) string
{
	final switch(type) with (Section.Type) {
	case Start: return "Start";
	case Content: return "Content";
	case End: return "End";
	case P: return "P";
	case Link: return "Link";
	case BriefStart: return "BriefStart";
	case BriefContent: return "BriefContent";
	case BriefEnd: return "BriefEnd";
	case ParamStart: return "ParamStart";
	case ParamContent: return "ParamContent";
	case ParamEnd: return "ParamEnd";
	}
}

class DocTester : vdoc.DocSink
{
public:
	fn test(src: string, expectedSequence: Section[])
	{
		mSequence = expectedSequence;
		vdoc.parse(src, this, null);
		assert(mSequence.length == 0);
	}

	override fn briefStart(sink: Sink)
	{
		check(Section.Type.BriefStart, "");
	}

	override fn briefEnd(sink: Sink)
	{
		check(Section.Type.BriefEnd, "");
	}

	override fn paramStart(direction: string, arg: string, sink: Sink)
	{
		check(Section.Type.ParamStart, direction ~ arg);
	}

	override fn paramEnd(sink: Sink)
	{
		check(Section.Type.ParamEnd, "");
	}

	override fn start(sink: Sink)
	{
		check(Section.Type.Start, "");
	}

	override fn end(sink: Sink)
	{
		check(Section.Type.End, "");
	}

	override fn content(state: vdoc.DocState, d: string, sink: Sink)
	{
		final switch (state) with (vdoc.DocState) {
		case Content: check(Section.Type.Content, d); break;
		case Brief: check(Section.Type.BriefContent, d); break;
		case Param: check(Section.Type.ParamContent, d); break;
		}
	}

	override fn p(state: vdoc.DocState, d: string, sink: Sink)
	{
		check(Section.Type.P, d);
	}

	override fn link(state: vdoc.DocState, link: string, sink: Sink)
	{
		check(Section.Type.Link, link);
	}

private:
	mSequence: Section[];

private:
	fn check(type: Section.Type, val: string)
	{
		assert(mSequence.length > 0);
		section := mSequence[0];
		mSequence = mSequence[1 .. $];
		assert(section.type == type);
		assert(section.val == val);
	}
}

fn main() i32
{
	tester := new DocTester();

	seq0 := new Section[](7);
	seq0[0].type = Section.Type.Start;
	seq0[1].type = Section.Type.Content;
	seq0[1].val  = "This is normal content.\n";
	seq0[2].type = Section.Type.BriefStart;
	seq0[3].type = Section.Type.BriefContent;
	seq0[3].val  = "This is ";
	seq0[4].type = Section.Type.P;
	seq0[4].val  = "";
	seq0[5].type = Section.Type.BriefEnd;
	seq0[6].type = Section.Type.End;
	tester.test("This is normal content.\n@brief This is @p", seq0);

	seq1 := new Section[](3);
	seq1[0].type = Section.Type.Start;
	seq1[1].type = Section.Type.Content;
	seq1[1].val  = "And this ";
	seq1[2].type = Section.Type.End;
	tester.test("And this @link doesn't end.", seq1);

	seq2 := new Section[](2);
	seq2[0].type = Section.Type.Start;
	seq2[1].type = Section.Type.End;
	tester.test("", seq2);

	seq3 := new Section[](3);
	seq3[0].type = Section.Type.Start;
	seq3[1].type = Section.Type.Content;
	seq3[1].val  = "@";
	seq3[2].type = Section.Type.End;
	tester.test("@", seq3);

	seq4 := new Section[](4);
	seq4[0].type = Section.Type.Start;
	seq4[1].type = Section.Type.ParamStart;
	seq4[1].val  = "a";
	seq4[2].type = Section.Type.ParamEnd;
	seq4[3].type = Section.Type.End;
	tester.test("@param a", seq4);

	return 0;
}
