import BlogModel from "../models/BlogModel.js";

// ** CRUD Controller Methods ** //

// Get all blogs
export const getAllBlogs = async (req, res) => {
  try {
    const blogs = await BlogModel.findAll();
    return res.status(200).json(blogs);
  } catch (error) {
    console.error("Error fetching blogs:", error);
    return res.status(500).json({ message: "Error fetching blogs", error: error.message });
  }
};

// Get one blog by ID
export const getBlog = async (req, res) => {
  try {
    const blog = await BlogModel.findOne({
      where: { id: req.params.id },
    });

    if (!blog) {
      return res.status(404).json({ message: "Blog not found" });
    }

    return res.status(200).json(blog);
  } catch (error) {
    console.error("Error fetching blog:", error);
    return res.status(500).json({ message: "Error fetching blog", error: error.message });
  }
};

// Create a new blog
export const createBlog = async (req, res) => {
  try {
    await BlogModel.create(req.body);
    return res.status(201).json({ message: "Blog created successfully!" });
  } catch (error) {
    console.error("Error creating blog:", error);
    return res.status(500).json({ message: "Error creating blog", error: error.message });
  }
};

// Update an existing blog
export const updateBlog = async (req, res) => {
  try {
    const [updatedRows] = await BlogModel.update(req.body, {
      where: { id: req.params.id },
    });

    if (updatedRows === 0) {
      return res.status(404).json({ message: "Blog not found" });
    }

    return res.status(200).json({ message: "Blog updated successfully!" });
  } catch (error) {
    console.error("Error updating blog:", error);
    return res.status(500).json({ message: "Error updating blog", error: error.message });
  }
};

// Delete a blog
export const deleteBlog = async (req, res) => {
  try {
    const deletedRows = await BlogModel.destroy({
      where: { id: req.params.id },
    });

    if (deletedRows === 0) {
      return res.status(404).json({ message: "Blog not found" });
    }

    return res.status(200).json({ message: "Blog deleted successfully!" });
  } catch (error) {
    console.error("Error deleting blog:", error);
    return res.status(500).json({ message: "Error deleting blog", error: error.message });
  }
};
